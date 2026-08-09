"""
Document processing utilities for PDF, DOC, and Images
"""
import pdfplumber
import pytesseract
from PIL import Image
from docx import Document
import os
from typing import Optional

async def extract_text_from_pdf(file_path: str) -> str:
    """Extract text from PDF file"""
    try:
        text = ""
        with pdfplumber.open(file_path) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        return text.strip()
    except Exception as e:
        raise Exception(f"Error extracting text from PDF: {str(e)}")

async def extract_text_from_docx(file_path: str) -> str:
    """Extract text from DOCX file"""
    try:
        doc = Document(file_path)
        text = "\n".join([paragraph.text for paragraph in doc.paragraphs])
        return text.strip()
    except Exception as e:
        raise Exception(f"Error extracting text from DOCX: {str(e)}")

async def extract_text_from_image(file_path: str) -> str:
    """Extract text from image using OCR"""
    try:
        image = Image.open(file_path)
        text = pytesseract.image_to_string(image)
        return text.strip()
    except Exception as e:
        raise Exception(f"Error extracting text from image: {str(e)}")

async def process_document(file_path: str, file_extension: str) -> str:
    """
    Process document based on file extension
    Returns extracted text
    """
    ext = file_extension.lower()
    
    if ext == ".pdf":
        return await extract_text_from_pdf(file_path)
    elif ext in [".docx", ".doc"]:
        return await extract_text_from_docx(file_path)
    elif ext in [".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff"]:
        return await extract_text_from_image(file_path)
    else:
        raise Exception(f"Unsupported file type: {ext}")

