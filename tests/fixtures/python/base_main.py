"""Base FastAPI Application"""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Base Application",
    description="Base application with core functionality",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
# app.include_router(users_router, prefix="/users", tags=["users"])
# app.include_router(auth_router, prefix="/auth", tags=["auth"])


@app.get("/")
def read_root():
    """Root endpoint"""
    return {"message": "Welcome to Base Application", "version": "1.0.0"}


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "base"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
