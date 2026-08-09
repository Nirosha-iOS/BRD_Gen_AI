"""
Technical Document Generation API endpoint
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from database import AsyncSessionLocal, Project, DocumentVersion
from utils.ai_client import generate_with_ollama, load_prompt_template
from datetime import datetime
import os

router = APIRouter()

class TechnicalDocRequest(BaseModel):
    project_id: int
    brd_version_id: Optional[int] = None
    custom_requirements: Optional[str] = None

class TechnicalDocResponse(BaseModel):
    project_id: int
    version_id: int
    tdd_content: str
    message: str

@router.post("/generate-technical-doc", response_model=TechnicalDocResponse)
async def generate_technical_doc(request: TechnicalDocRequest):
    """
    Generate Technical Design Document (TDD) from BRD or requirements
    """
    try:
        async with AsyncSessionLocal() as session:
            # Get requirements text
            if request.custom_requirements:
                requirements_text = request.custom_requirements
            elif request.brd_version_id:
                result = await session.execute(
                    select(DocumentVersion).where(DocumentVersion.id == request.brd_version_id)
                )
                brd_version = result.scalar_one_or_none()
                if not brd_version or brd_version.document_type != "BRD":
                    raise HTTPException(status_code=404, detail="BRD version not found")
                requirements_text = brd_version.content
            else:
                # Get latest BRD for project
                result = await session.execute(
                    select(DocumentVersion)
                    .where(
                        DocumentVersion.project_id == request.project_id,
                        DocumentVersion.document_type == "BRD"
                    )
                    .order_by(DocumentVersion.version_number.desc())
                    .limit(1)
                )
                brd_version = result.scalars().first()
                if not brd_version:
                    raise HTTPException(status_code=404, detail="No BRD found for project")
                requirements_text = brd_version.content
            
            # Load TDD prompt template
            template = load_prompt_template("tdd")
            prompt = template.format(input_text=requirements_text)
            
            # Generate TDD using Ollama
            tdd_content = await generate_with_ollama(prompt)
            
            # Save TDD version
            doc_version = DocumentVersion(
                project_id=request.project_id,
                version_number=1,  # TDD versions start at 1
                document_type="TDD",
                content=tdd_content,
                created_at=datetime.utcnow()
            )
            session.add(doc_version)
            await session.commit()
            
            # Save to file
            file_path = os.path.join(
                "storage", "documents",
                f"TDD_Project_{request.project_id}.txt"
            )
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(tdd_content)
            
            doc_version.file_path = file_path
            await session.commit()
            
            return TechnicalDocResponse(
                project_id=request.project_id,
                version_id=doc_version.id,
                tdd_content=tdd_content,
                message="Technical Document generated successfully"
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

