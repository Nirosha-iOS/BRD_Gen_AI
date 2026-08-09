"""
BRD Generation API endpoint
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from database import AsyncSessionLocal, Project, InputText, DocumentVersion
from utils.ai_client import generate_with_ollama, load_prompt_template
from datetime import datetime
import os

router = APIRouter()

class BRDGenerateRequest(BaseModel):
    project_id: int
    input_id: Optional[int] = None
    custom_text: Optional[str] = None

class BRDGenerateResponse(BaseModel):
    project_id: int
    version_id: int
    version_number: int
    brd_content: str
    message: str

@router.post("/generate-brd", response_model=BRDGenerateResponse)
async def generate_brd(request: BRDGenerateRequest):
    """
    Generate BRD from processed input text
    """
    import logging
    logger = logging.getLogger(__name__)
    
    try:
        async with AsyncSessionLocal() as session:
            # Get input text
            if request.custom_text:
                input_text = request.custom_text
            elif request.input_id:
                result = await session.execute(
                    select(InputText).where(InputText.id == request.input_id)
                )
                input_record = result.scalar_one_or_none()
                if not input_record:
                    raise HTTPException(status_code=404, detail="Input not found")
                input_text = input_record.content
            else:
                # Get latest input for project
                result = await session.execute(
                    select(InputText)
                    .where(InputText.project_id == request.project_id)
                    .order_by(InputText.created_at.desc())
                    .limit(1)
                )
                input_record = result.scalars().first()
                if not input_record:
                    raise HTTPException(status_code=404, detail="No input found for project")
                input_text = input_record.content
            
            # Get latest version number
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
            next_version = (latest_version.version_number + 1) if latest_version else 1
            
            # Load BRD prompt template
            template = load_prompt_template("brd")
            if not template:
                raise HTTPException(status_code=500, detail="Failed to load BRD template")
            
            # Replace {input_text} placeholder safely
            prompt = template.replace("{input_text}", input_text)
            
            logger.info(f"Generating BRD for project {request.project_id}, prompt length: {len(prompt)}")
            
            # Generate BRD using Ollama
            brd_content = await generate_with_ollama(prompt)
            
            if not brd_content or brd_content.strip() == "":
                raise HTTPException(status_code=500, detail="Ollama returned empty response")
            
            # Save BRD version
            doc_version = DocumentVersion(
                project_id=request.project_id,
                version_number=next_version,
                document_type="BRD",
                content=brd_content,
                created_at=datetime.utcnow()
            )
            session.add(doc_version)
            await session.commit()
            
            # Save to file
            file_path = os.path.join(
                "storage", "documents",
                f"BRD_Project_{request.project_id}_v{next_version}.txt"
            )
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(brd_content)
            
            doc_version.file_path = file_path
            await session.commit()
            
            return BRDGenerateResponse(
                project_id=request.project_id,
                version_id=doc_version.id,
                version_number=next_version,
                brd_content=brd_content,
                message=f"BRD v{next_version} generated successfully"
            )
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        error_details = f"{str(e)}\n\nTraceback:\n{error_trace}"
        logger.error(f"BRD generation failed: {error_details}")
        # Return a more user-friendly error message
        raise HTTPException(
            status_code=500, 
            detail=f"Failed to generate BRD: {str(e)}. Please check if Ollama is running and the model is available."
        )

