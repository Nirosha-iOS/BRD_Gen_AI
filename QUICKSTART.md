# Quick Start Guide

Get up and running in 5 minutes!

## Prerequisites Check

```bash
# Check Python
python3 --version  # Should be 3.10+

# Check Flutter
flutter --version

# Check Ollama
ollama --version
```

## Installation

### Option 1: Automated (Recommended)

```bash
./install.sh
```

### Option 2: Manual

```bash
# Backend
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Frontend
cd ../frontend
flutter pub get
flutter config --enable-web

# Ollama Model
ollama pull llama3
```

## Running the Application

### Terminal 1: Backend
```bash
./start_backend.sh
# OR
cd backend && source venv/bin/activate && uvicorn main:app --reload
```

### Terminal 2: Frontend
```bash
./start_frontend.sh
# OR
cd frontend && flutter run -d chrome
```

### Terminal 3: Ollama (if not running as service)
```bash
ollama serve
```

## First Use

1. **Open Browser**: Frontend should open automatically at `http://localhost:4200`
2. **Input Tab**: 
   - Enter project name
   - Type or upload your requirements
   - Click "Process Text" or upload file
3. **BRD Tab**: Click "Generate BRD" (wait 30-60 seconds)
4. **Feedback Tab**: Enter feedback and update BRD
5. **Technical Tab**: Generate technical document

## Troubleshooting

**Backend not starting?**
- Check Python version: `python3 --version`
- Activate venv: `source backend/venv/bin/activate`
- Install deps: `pip install -r backend/requirements.txt`

**Frontend not starting?**
- Check Flutter: `flutter doctor`
- Get deps: `cd frontend && flutter pub get`

**Ollama errors?**
- Start Ollama: `ollama serve`
- Check model: `ollama list`
- Pull model: `ollama pull llama3`

**Slow generation?**
- Use smaller model: `ollama pull mistral` (faster)
- Update `.env`: `OLLAMA_MODEL=mistral`

## Need Help?

See `SETUP.md` for detailed instructions.

