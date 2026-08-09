#!/bin/bash

# BRD AI Generator - Installation Script
# This script helps set up the development environment

set -e

echo "🚀 BRD AI Generator - Installation Script"
echo "=========================================="
echo ""

# Check Python
echo "📦 Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python found: $PYTHON_VERSION"
else
    echo "❌ Python 3.10+ is required. Please install Python first."
    exit 1
fi

# Check Flutter
echo "📦 Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo "✅ Flutter found: $FLUTTER_VERSION"
else
    echo "❌ Flutter is required. Please install Flutter first."
    exit 1
fi

# Check Ollama
echo "📦 Checking Ollama installation..."
if command -v ollama &> /dev/null; then
    echo "✅ Ollama found"
else
    echo "⚠️  Ollama not found. Installing..."
    curl -fsSL https://ollama.ai/install.sh | sh
fi

# Check Tesseract
echo "📦 Checking Tesseract OCR..."
if command -v tesseract &> /dev/null; then
    TESSERACT_VERSION=$(tesseract --version | head -n 1)
    echo "✅ Tesseract found: $TESSERACT_VERSION"
else
    echo "⚠️  Tesseract OCR not found."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "   Install with: brew install tesseract"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "   Install with: sudo apt-get install tesseract-ocr"
    else
        echo "   Please install Tesseract OCR manually"
    fi
fi

# Setup Backend
echo ""
echo "🔧 Setting up Backend..."
cd backend

if [ ! -d "venv" ]; then
    echo "   Creating virtual environment..."
    python3 -m venv venv
fi

echo "   Activating virtual environment..."
source venv/bin/activate

echo "   Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "   ✅ Backend setup complete!"
deactivate
cd ..

# Setup Frontend
echo ""
echo "🔧 Setting up Frontend..."
cd frontend

echo "   Getting Flutter dependencies..."
flutter pub get

echo "   Enabling web support..."
flutter config --enable-web

echo "   ✅ Frontend setup complete!"
cd ..

# Create storage directories
echo ""
echo "📁 Creating storage directories..."
mkdir -p storage/uploads storage/documents storage/audio
echo "   ✅ Storage directories created!"

# Pull Ollama model
echo ""
echo "🤖 Setting up Ollama model..."
echo "   This may take a few minutes..."
ollama pull llama3 || echo "   ⚠️  Could not pull llama3. You can do this manually later with: ollama pull llama3"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Start Ollama (if not running): ollama serve"
echo "   2. Start Backend: cd backend && source venv/bin/activate && uvicorn main:app --reload"
echo "   3. Start Frontend: cd frontend && flutter run -d chrome"
echo ""
echo "📖 See SETUP.md for detailed instructions"

