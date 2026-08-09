"""
Script to clear all projects from the database
"""
import asyncio
from sqlalchemy import delete
from database import AsyncSessionLocal, Project, InputText, DocumentVersion

async def clear_all_projects():
    """
    Delete all projects and related data
    """
    async with AsyncSessionLocal() as session:
        try:
            # Delete all document versions
            await session.execute(delete(DocumentVersion))
            print("✓ Deleted all document versions")
            
            # Delete all input texts
            await session.execute(delete(InputText))
            print("✓ Deleted all input texts")
            
            # Delete all projects
            await session.execute(delete(Project))
            print("✓ Deleted all projects")
            
            # Commit changes
            await session.commit()
            print("\n✅ All projects and related data have been cleared successfully!")
            
        except Exception as e:
            await session.rollback()
            print(f"❌ Error clearing projects: {str(e)}")
            raise

if __name__ == "__main__":
    asyncio.run(clear_all_projects())

