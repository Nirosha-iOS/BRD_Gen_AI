"""
Text Input API endpoint
"""
from fastapi import APIRouter, HTTPException
from typing import Optional
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from database import AsyncSessionLocal, Project, InputText
from datetime import datetime

router = APIRouter()

class TextInputRequest(BaseModel):
    text: str
    project_name: str = "Untitled Project"
    project_type: str = "Software"
    project_id: Optional[int] = None  # Optional: if provided, use existing project

class TextInputResponse(BaseModel):
    project_id: int
    input_id: int
    extracted_text: str
    message: str

@router.post("/text-input", response_model=TextInputResponse)
async def process_text_input(request: TextInputRequest):
    """
    Accept text input and store it for BRD generation
    """
    try:
        async with AsyncSessionLocal() as session:
            # Use existing project if project_id is provided
            if request.project_id:
                result = await session.execute(
                    select(Project).where(Project.id == request.project_id)
                )
                project = result.scalar_one_or_none()
                if not project:
                    raise HTTPException(status_code=404, detail="Project not found")
            else:
                # Create new project
                project = Project(
                    name=request.project_name,
                    project_type=request.project_type,
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                session.add(project)
                await session.flush()
            
            # Store input text
            input_text = InputText(
                project_id=project.id,
                input_type="text",
                content=request.text,
                created_at=datetime.utcnow()
            )
            session.add(input_text)
            await session.commit()
            
            return TextInputResponse(
                project_id=project.id,
                input_id=input_text.id,
                extracted_text=request.text,
                message="Text input processed successfully"
            )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

