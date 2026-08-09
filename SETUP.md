# Setup Guide - BRD AI Generator Phase-1

This guide will help you set up the AI-Powered BRD Generator on your local machine.

## Prerequisites

### System Requirements
- **Python 3.10+** (Check with `python3 --version`)
- **Flutter SDK** (Check with `flutter --version`)
- **Ollama** (Local LLM)
- **Tesseract OCR** (For image/PDF text extraction)
- **FFmpeg** (For audio processing, usually comes with Whisper)

### macOS Installation

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.10+
brew install python@3.10

# Install Tesseract OCR
brew install tesseract

# Install FFmpeg (for audio processing)
brew install ffmpeg

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Install Flutter
brew install --cask flutter
```

### Linux (Ubuntu/Debian) Installation

```bash
# Update package list
sudo apt-get update

# Install Python 3.10+
sudo apt-get install python3.10 python3-pip

# Install Tesseract OCR
sudo apt-get install tesseract-ocr

# Install FFmpeg
sudo apt-get install ffmpeg

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Install Flutter
# Follow instructions at https://docs.flutter.dev/get-started/install/linux
```

### Windows Installation

1. **Python**: Download from https://www.python.org/downloads/
2. **Tesseract**: Download from https://github.com/UB-Mannheim/tesseract/wiki
3. **FFmpeg**: Download from https://ffmpeg.org/download.html
4. **Ollama**: Download from https://ollama.ai/download
5. **Flutter**: Follow instructions at https://docs.flutter.dev/get-started/install/windows

## Step-by-Step Setup

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment (recommended)
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install Python dependencies
pip install -r requirements.txt

# Note: Whisper will download models automatically on first use
```

### 2. Install and Setup Ollama

```bash
# Pull a model (llama3 is recommended, but you can use smaller models)
ollama pull llama3

# For faster processing, you can use smaller models:
# ollama pull mistral
# ollama pull phi3

# Verify Ollama is running
ollama list
```

### 3. Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Get Flutter dependencies
flutter pub get

# Enable web support
flutter config --enable-web
```

### 4. Create Storage Directories

```bash
# From project root
mkdir -p storage/uploads storage/documents storage/audio
```

## Running the Application

### Terminal 1: Start Backend

```bash
cd backend
source venv/bin/activate  # On Windows: venv\Scripts\activate
uvicorn main:app --reload --port 8000
```

The backend will be available at: `http://localhost:8000`

### Terminal 2: Start Frontend

```bash
cd frontend
flutter run -d chrome
```

The frontend will open in your browser at: `http://localhost:4200` (or similar port)

## Verification

1. **Backend Health Check**: Visit `http://localhost:8000/health` - should return `{"status": "healthy"}`

2. **Ollama Check**: Run `ollama list` - should show your installed model

3. **Frontend**: Should open automatically in browser

## Troubleshooting

### Ollama Connection Issues
- Ensure Ollama is running: `ollama serve` (if not running as service)
- Check Ollama URL in `backend/utils/ai_client.py` (default: `http://localhost:11434`)

### Tesseract OCR Issues
- Verify installation: `tesseract --version`
- On macOS, ensure path is correct: `/opt/homebrew/bin/tesseract` or `/usr/local/bin/tesseract`

### Whisper Model Download
- First audio transcription will download the model (~150MB for 'base' model)
- This happens automatically, just wait for the first transcription

### Port Conflicts
- Backend default: 8000 (change in `backend/main.py`)
- Frontend default: 4200 (Flutter auto-assigns)

### Database Issues
- SQLite database is created automatically at `storage/brd_versions.db`
- Delete this file to reset all data

## Environment Variables (Optional)

Create a `.env` file in the `backend` directory:

```env
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3
```

## Testing the Application

1. **Text Input**: Go to Input tab → Enter text → Click "Process Text"
2. **BRD Generation**: Go to BRD tab → Click "Generate BRD"
3. **Feedback**: Go to Feedback tab → Enter feedback → Click "Update BRD"
4. **Technical Doc**: Go to Technical tab → Click "Generate TDD"

## Next Steps

- Customize prompt templates in `prompts/` directory
- Adjust model size based on your hardware (smaller = faster, larger = better quality)
- Review generated documents and refine prompts as needed

## Support

For issues or questions:
1. Check the logs in terminal windows
2. Verify all prerequisites are installed
3. Ensure all services are running (Ollama, Backend, Frontend)

