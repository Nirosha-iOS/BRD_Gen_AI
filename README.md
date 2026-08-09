# AI-Powered BRD Generator - Phase 1

A local, offline, free AI tool for generating Business Requirement Documents (BRD) and Technical Documents (TDD).

## Project Structure

```
BRD_AI/
├── backend/          # Python FastAPI backend
├── frontend/         # Flutter Web frontend
├── prompts/          # AI prompt templates
└── storage/          # Local storage (SQLite, documents)
```

## Setup Instructions

### Backend Setup

1. Install Python 3.10+
2. Install dependencies:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```
3. Install system dependencies:
   - **Ollama**: Download from https://ollama.ai
   - **Tesseract OCR**: `brew install tesseract` (macOS) or `apt-get install tesseract-ocr` (Linux)
   - **Whisper**: Included via `openai-whisper` package
4. Pull Ollama model:
   ```bash
   ollama pull llama3
   ```
5. Run backend:
   ```bash
   cd backend
   uvicorn main:app --reload --port 8000
   ```

### Frontend Setup

1. Install Flutter SDK
2. Enable Flutter Web:
   ```bash
   flutter config --enable-web
   ```
3. Run frontend:
   ```bash
   cd frontend
   flutter run -d chrome
   ```

## Features

- ✅ Text input processing
- ✅ Voice transcription (Whisper)
- ✅ Document processing (PDF/DOC/Images with OCR)
- ✅ BRD generation using local LLM (Ollama)
- ✅ Technical Document generation
- ✅ Feedback-based BRD updates
- ✅ Version management (SQLite)
- ✅ Fully offline and free

## API Endpoints

- `POST /api/text-input` - Process text input
- `POST /api/audio-upload` - Upload and transcribe audio
- `POST /api/doc-upload` - Upload and process documents
- `POST /api/generate-brd` - Generate BRD from processed text
- `POST /api/generate-technical-doc` - Generate technical document
- `POST /api/update-brd` - Update BRD based on feedback
- `GET /api/versions/{project_id}` - Get version history
- `GET /api/download/{version_id}` - Download document

