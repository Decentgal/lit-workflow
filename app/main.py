import os
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app import __version__  
from app.routes.health import router as health_router

# Application Insights Setup
# Only activates when the environment variable is present. It is absent locally.
connection_string = os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING")

if connection_string:
    from opencensus.ext.azure.log_exporter import AzureLogHandler
    logger = logging.getLogger(__name__)
    logger.addHandler(AzureLogHandler(connection_string=connection_string))
    logging.basicConfig(level=logging.INFO)

# App Initialisation
app = FastAPI(
    title="WOGO API",
    description="WOGO Enterprise FastAPI Service",
    version=__version__,
    docs_url="/docs",           
    redoc_url="/redoc",         
    openapi_url="/openapi.json" 
)

# Security Middleware
# In a real workload, I'd put the actual frontend domains/URLs rather the astericks.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# Register Routers 
app.include_router(health_router, prefix="/api/v1")


# Root Endpoint 
@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint — confirms the API is running.
    """
    return {
        "message": "WOGO API is live",
        "status": "healthy",
        "version": __version__,
        "docs": "/docs"
    }