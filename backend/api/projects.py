"""
Projects API endpoints
"""
from fastapi import APIRouter, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, delete
from database import AsyncSessionLocal, Project, InputText, DocumentVersion
from typing import List
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class ProjectInfo(BaseModel):
    id: int
    name: str
    project_type: str
    created_at: str
    updated_at: str

class ProjectsListResponse(BaseModel):
    projects: List[ProjectInfo]

@router.get("/projects", response_model=ProjectsListResponse)
async def get_all_projects():
    """
    Get all projects
    """
    try:
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                select(Project).order_by(Project.created_at.desc())
            )
            projects = result.scalars().all()
            
            project_list = [
                ProjectInfo(
                    id=p.id,
                    name=p.name,
                    project_type=p.project_type,
                    created_at=p.created_at.isoformat(),
                    updated_at=p.updated_at.isoformat()
                )
                for p in projects
            ]
            
            return ProjectsListResponse(projects=project_list)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/projects/{project_id}", response_model=ProjectInfo)
async def get_project(project_id: int):
    """
    Get a specific project by ID
    """
    try:
        async with AsyncSessionLocal() as session:
            result = await session.execute(
                select(Project).where(Project.id == project_id)
            )
            project = result.scalar_one_or_none()
            
            if not project:
                raise HTTPException(status_code=404, detail="Project not found")
            
            return ProjectInfo(
                id=project.id,
                name=project.name,
                project_type=project.project_type,
                created_at=project.created_at.isoformat(),
                updated_at=project.updated_at.isoformat()
            )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/projects/clear-all")
async def clear_all_projects():
    """
    Delete all projects and related data (for testing/reset purposes)
    """
    try:
        async with AsyncSessionLocal() as session:
            # Delete all document versions
            await session.execute(delete(DocumentVersion))
            
            # Delete all input texts
            await session.execute(delete(InputText))
            
            # Delete all projects
            await session.execute(delete(Project))
            
            # Commit changes
            await session.commit()
            
            return {"message": "All projects and related data have been cleared successfully", "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error clearing projects: {str(e)}")

