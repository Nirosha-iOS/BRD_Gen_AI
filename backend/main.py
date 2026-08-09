"""
FastAPI Backend for AI-Powered BRD Generator
"""
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
from typing import Optional, List
import uvicorn
import os
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

from api.text_input import router as text_router
from api.audio_upload import router as audio_router
from api.doc_upload import router as doc_router
from api.brd_generator import router as brd_router
from api.technical_doc import router as technical_router
from api.feedback_update import router as feedback_router
from api.versions import router as versions_router
from api.projects import router as projects_router
from database import init_db

app = FastAPI(title="BRD AI Generator API", version="1.0.0")

# CORS middleware for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:4200", "http://127.0.0.1:4200", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(projects_router, prefix="/api", tags=["Projects"])
app.include_router(text_router, prefix="/api", tags=["Text Input"])
app.include_router(audio_router, prefix="/api", tags=["Audio"])
app.include_router(doc_router, prefix="/api", tags=["Documents"])
app.include_router(brd_router, prefix="/api", tags=["BRD"])
app.include_router(technical_router, prefix="/api", tags=["Technical"])
app.include_router(feedback_router, prefix="/api", tags=["Feedback"])
app.include_router(versions_router, prefix="/api", tags=["Versions"])

@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    await init_db()
    # Create storage directories
    os.makedirs("storage/uploads", exist_ok=True)
    os.makedirs("storage/documents", exist_ok=True)
    os.makedirs("storage/audio", exist_ok=True)

@app.get("/")
async def root():
    return {"message": "BRD AI Generator API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

