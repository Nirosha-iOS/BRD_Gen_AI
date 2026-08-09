# How to Run the Application

## Quick Start Guide

You need **3 terminal windows** to run the complete application.

---

## Terminal 1: Start Ollama (AI Service)

**Required for BRD generation to work**

```bash
# Start Ollama service
ollama serve
```

**Keep this terminal open** - Ollama needs to keep running.

**First time only**: Pull an AI model (in a new terminal or after starting Ollama):
```bash
ollama pull llama3
# OR for faster processing:
ollama pull mistral
```

---

## Terminal 2: Start Backend (FastAPI)

**Required for API endpoints**

```bash
# Navigate to backend directory
cd /Users/nirosha/Documents/BRD_AI/backend

# Activate virtual environment
source venv/bin/activate

# Start the server
uvicorn main:app --reload --port 8000
```

**You should see:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000
INFO:     Application startup complete.
```

**Keep this terminal open** - Backend needs to keep running.

**Test it**: Open browser and visit:
- http://localhost:8000 (should show `{"message":"BRD AI Generator API","status":"running"}`)
- http://localhost:8000/docs (API documentation)

---

## Terminal 3: Start Frontend (Flutter Web)

**Required for the user interface**

```bash
# Navigate to frontend directory
cd /Users/nirosha/Documents/BRD_AI/frontend

# Start Flutter web app
flutter run -d chrome
```

**Flutter will:**
- Build the web app (first time takes a few minutes)
- Open Chrome automatically
- Show the application at `http://localhost:4200` (or similar port)

**Keep this terminal open** - Frontend needs to keep running.

---

## Using the Application

1. **Open the Flutter app** in your browser (usually opens automatically)
2. **Go to Input tab**:
   - Enter project name
   - Type your requirements OR upload a file/audio
   - Click "Process Text" or upload
3. **Go to BRD tab**:
   - Click "Generate BRD"
   - Wait 30-60 seconds for generation
   - View and download the BRD
4. **Go to Feedback tab**:
   - Enter feedback
   - Click "Update BRD" to create a new version
5. **Go to Technical tab**:
   - Generate technical documentation

---

## Alternative: Using Startup Scripts

If you prefer using the provided scripts:

### Start Backend:
```bash
cd /Users/nirosha/Documents/BRD_AI
./start_backend.sh
```

### Start Frontend:
```bash
cd /Users/nirosha/Documents/BRD_AI
./start_frontend.sh
```

---

## Troubleshooting

### Backend won't start?
- Check if port 8000 is already in use: `lsof -ti:8000`
- Make sure virtual environment is activated: `source venv/bin/activate`
- Check for errors in the terminal output

### Frontend won't start?
- Make sure Flutter is installed: `flutter doctor`
- Get dependencies: `cd frontend && flutter pub get`
- Check if Chrome is installed

### Ollama errors?
- Make sure Ollama is running: `ollama list` (should not error)
- Check if model is pulled: `ollama list` (should show your model)
- Restart Ollama: Stop and run `ollama serve` again

### BRD generation fails?
- Make sure Ollama is running (Terminal 1)
- Make sure a model is pulled: `ollama pull llama3`
- Check backend logs for errors

---

## Stopping the Application

1. **Stop Frontend**: Press `Ctrl+C` in Terminal 3
2. **Stop Backend**: Press `Ctrl+C` in Terminal 2
3. **Stop Ollama**: Press `Ctrl+C` in Terminal 1

---

## Quick Reference

| Service | Terminal | Command | URL |
|---------|----------|---------|-----|
| Ollama | 1 | `ollama serve` | http://localhost:11434 |
| Backend | 2 | `uvicorn main:app --reload` | http://localhost:8000 |
| Frontend | 3 | `flutter run -d chrome` | http://localhost:4200 |

---

## One-Line Commands (Copy & Paste)

### Terminal 1 (Ollama):
```bash
ollama serve
```

### Terminal 2 (Backend):
```bash
cd /Users/nirosha/Documents/BRD_AI/backend && source venv/bin/activate && uvicorn main:app --reload --port 8000
```

### Terminal 3 (Frontend):
```bash
cd /Users/nirosha/Documents/BRD_AI/frontend && flutter run -d chrome
```

---

## First Time Setup (One-time)

If you haven't pulled an AI model yet:
```bash
ollama pull llama3
```

This downloads ~4GB and takes a few minutes. You only need to do this once.

