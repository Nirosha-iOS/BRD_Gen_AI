"""
Audio Upload and Transcription API endpoint
"""
from fastapi import APIRouter, UploadFile, File, HTTPException, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from database import AsyncSessionLocal, Project, InputText
from utils.audio_processor import transcribe_audio
from datetime import datetime
from typing import Optional
import aiofiles
import os
import uuid

router = APIRouter()

@router.post("/audio-upload")
async def upload_audio(
    file: UploadFile = File(...),
    project_name: str = Form("Untitled Project"),
    project_type: str = Form("Software"),
    project_id: Optional[int] = Form(None)
):
    """
    Upload audio file, transcribe using Whisper, and store for BRD generation
    """
    try:
        # Save uploaded file
        file_extension = os.path.splitext(file.filename)[1]
        file_id = str(uuid.uuid4())
        audio_path = os.path.join("storage", "audio", f"{file_id}{file_extension}")
        
        os.makedirs(os.path.dirname(audio_path), exist_ok=True)
        
        async with aiofiles.open(audio_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        # Transcribe audio
        transcribed_text = await transcribe_audio(audio_path)
        
        # Store in database
        async with AsyncSessionLocal() as session:
            # Use existing project if project_id is provided
            if project_id:
                result = await session.execute(
                    select(Project).where(Project.id == project_id)
                )
                project = result.scalar_one_or_none()
                if not project:
                    raise HTTPException(status_code=404, detail="Project not found")
            else:
                # Create new project
                project = Project(
                    name=project_name,
                    project_type=project_type,
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                session.add(project)
                await session.flush()
            
            # Store transcribed text
            input_text = InputText(
                project_id=project.id,
                input_type="audio",
                content=transcribed_text,
                file_path=audio_path,
                created_at=datetime.utcnow()
            )
            session.add(input_text)
            await session.commit()
            
            return {
                "project_id": project.id,
                "input_id": input_text.id,
                "extracted_text": transcribed_text,
                "message": "Audio transcribed successfully",
                "audio_path": audio_path
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

