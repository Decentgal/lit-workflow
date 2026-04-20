from fastapi import APIRouter
from app import __version__ 

router = APIRouter(tags=["Health"])

@router.get("/health")
async def health_check():
    """
    Health check endpoint.
    Azure App Service uses this to confirm the container is alive.
    OWASP ZAP also hits this during DAST scanning.
    """
    return {
        "status": "healthy",
        "service": "wogo-api",  
        "version": __version__,
    }