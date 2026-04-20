# This is the BUILDER stage 1. It installs all dependencies in an isolated layer, gets deleted after building. 
# Nothing in this stage ever makes it to production.

FROM python:3.11-slim AS builder

WORKDIR /app

# Install dependencies first then its layer gets cached by Docker so re-builds are faster when there's code changes.
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# This is RUNTIME stage 2 and it's the final, lean image that actually runs in production.
# This stage contains only what is needed to run the Python-FastAPI app.

FROM python:3.11-slim AS runtime

# I'm running this block because containers shold never be run as root/privileged user.
# So, I'll create a standard system user called 'appuser' and run my Python-FastAPI app as appuser.
RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copy installed packages from the Builder stage 1
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy only the application code in the /app folder. (not terraform, pipelines, or tests)
COPY app/ ./app/

# Give the /app folder to appuser
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Tell Docker this container listens on port 8000
EXPOSE 8000

# This is a health check Azure App Service uses to know if the container is alive.
# It tries every 30 seconds. If it fails 3 times, Azure restarts the container.
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import httpx; r = httpx.get('http://localhost:8000/api/v1/health'); exit(0 if r.status_code == 200 else 1)"

# Start the FastAPI app with uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]