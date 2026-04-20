import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from app.main import app
from app import __version__

# TEST SETUP (FIXTURES)

@pytest_asyncio.fixture
async def async_client():
    """Creates a reusable asynchronous test client."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        yield client

# ROOT ENDPOINT TESTS

@pytest.mark.asyncio
async def test_root_returns_200(async_client):
    """Root endpoint must return HTTP 200."""
    response = await async_client.get("/")
    assert response.status_code == 200

@pytest.mark.asyncio
async def test_root_status_is_healthy(async_client):
    """Root endpoint must confirm the service is healthy."""
    response = await async_client.get("/")
    assert response.json()["status"] == "healthy" 

@pytest.mark.asyncio
async def test_root_returns_correct_version(async_client):
    """Root endpoint must return the dynamic API version."""
    response = await async_client.get("/")
    assert response.json()["version"] == __version__

# HEALTH ENDPOINT TESTS

@pytest.mark.asyncio
async def test_health_returns_200(async_client):
    """Health endpoint must return HTTP 200."""
    response = await async_client.get("/api/v1/health")
    assert response.status_code == 200

@pytest.mark.asyncio
async def test_health_status_is_healthy(async_client):
    """Health endpoint must return healthy status."""
    response = await async_client.get("/api/v1/health")
    assert response.json()["status"] == "healthy"

@pytest.mark.asyncio
async def test_health_returns_service_name(async_client):
    """Health endpoint must identify the WOGO service correctly."""
    response = await async_client.get("/api/v1/health")
    assert response.json()["service"] == "wogo-api"

# OPENAPI SCHEMA TEST

@pytest.mark.asyncio
async def test_openapi_schema_is_accessible(async_client):
    """OpenAPI schema must be accessible — OWASP ZAP depends on this for DAST."""
    response = await async_client.get("/openapi.json")
    assert response.status_code == 200
    assert "openapi" in response.json()