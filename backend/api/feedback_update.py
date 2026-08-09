"""
Feedback-based BRD Update API endpoint
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from database import AsyncSessionLocal, DocumentVersion
from utils.ai_client import generate_with_ollama, load_prompt_template
from datetime import datetime
import os

router = APIRouter()

class FeedbackUpdateRequest(BaseModel):
    project_id: int
    current_version_id: int
    feedback: str

class FeedbackUpdateResponse(BaseModel):
    project_id: int
    new_version_id: int
    new_version_number: int
    updated_brd_content: str
    message: str

@router.post("/update-brd", response_model=FeedbackUpdateResponse)
async def update_brd_with_feedback(request: FeedbackUpdateRequest):
    """
    Update BRD based on client feedback
    """
    try:
        async with AsyncSessionLocal() as session:
            # Get current BRD version
            result = await session.execute(
                select(DocumentVersion).where(DocumentVersion.id == request.current_version_id)
            )
            current_version = result.scalar_one_or_none()
            
            if not current_version or current_version.document_type != "BRD":
                raise HTTPException(status_code=404, detail="BRD version not found")
            
            # Get next version number
            result = await session.execute(
                select(DocumentVersion)
                .where(
                    DocumentVersion.project_id == request.project_id,
                    DocumentVersion.document_type == "BRD"
                )
                .order_by(DocumentVersion.version_number.desc())
                .limit(1)
            )
            latest_version = result.scalars().first()
            next_version = (latest_version.version_number + 1) if latest_version else current_version.version_number + 1
            
            # Load feedback update prompt template
            template = load_prompt_template("feedback_update")
            prompt = template.format(
                current_brd=current_version.content,
                feedback=request.feedback,
                version=current_version.version_number,
                new_version=next_version
            )
            
            # Generate updated BRD using Ollama
            updated_brd_content = await generate_with_ollama(prompt)
            
            # Save new BRD version with feedback
            new_version = DocumentVersion(
                project_id=request.project_id,
                version_number=next_version,
                document_type="BRD",
                content=updated_brd_content,
                feedback=request.feedback,
                created_at=datetime.utcnow()
            )
            session.add(new_version)
            await session.commit()
            
            # Save to file
            file_path = os.path.join(
                "storage", "documents",
                f"BRD_Project_{request.project_id}_v{next_version}.txt"
            )
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(updated_brd_content)
            
            new_version.file_path = file_path
            await session.commit()
            
            return FeedbackUpdateResponse(
                project_id=request.project_id,
                new_version_id=new_version.id,
                new_version_number=next_version,
                updated_brd_content=updated_brd_content,
                message=f"BRD updated to v{next_version} based on feedback"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

