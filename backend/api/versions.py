"""
Version Management API endpoints
"""
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from database import AsyncSessionLocal, Project, DocumentVersion
from typing import List
from pydantic import BaseModel
import os

router = APIRouter()

class VersionInfo(BaseModel):
    id: int
    version_number: int
    document_type: str
    created_at: str
    feedback: str = None
    file_path: str = None

class ProjectVersionsResponse(BaseModel):
    project_id: int
    project_name: str
    versions: List[VersionInfo]

@router.get("/versions/{project_id}", response_model=ProjectVersionsResponse)
async def get_project_versions(project_id: int):
    """
    Get all versions for a project
    """
    try:
        async with AsyncSessionLocal() as session:
            # Get project
            result = await session.execute(
                select(Project).where(Project.id == project_id)
            )
            project = result.scalar_one_or_none()
            if not project:
                raise HTTPException(status_code=404, detail="Project not found")
            
            # Get all versions
            result = await session.execute(
                select(DocumentVersion)
                .where(DocumentVersion.project_id == project_id)
                .order_by(DocumentVersion.created_at.desc())
            )
            versions = result.scalars().all()
            
            version_list = [
                VersionInfo(
                    id=v.id,
                    version_number=v.version_number,
                    document_type=v.document_type,
                    created_at=v.created_at.isoformat(),
                    feedback=v.feedback,
                    file_path=v.file_path
                )
                for v in versions
            ]
            
            return ProjectVersionsResponse(
                project_id=project.id,
                project_name=project.name,
                versions=version_list
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/download/{version_id}")
async def download_document(version_id: int):
    """
    Download a specific document version
    """
    try:
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                select(DocumentVersion).where(DocumentVersion.id == version_id)
            )
            version = result.scalar_one_or_none()
            
            if not version:
                raise HTTPException(status_code=404, detail="Version not found")
            
            if version.file_path and os.path.exists(version.file_path):
                return FileResponse(
                    version.file_path,
                    media_type="text/plain",
                    filename=f"{version.document_type}_v{version.version_number}.txt"
                )
            else:
                # Return content as text file
                return Response(
                    content=version.content,
                    media_type="text/plain",
                    headers={
                        "Content-Disposition": f"attachment; filename={version.document_type}_v{version.version_number}.txt"
                    }
                )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

