#!/bin/bash

# Start Backend Server
cd "$(dirname "$0")/backend"

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "⚠️  Virtual environment not found. Creating one..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
fi

# Start server
echo "🚀 Starting Backend Server on http://localhost:8000"
uvicorn main:app --reload --port 8000

