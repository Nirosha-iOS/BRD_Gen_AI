"""
Audio processing using Whisper for transcription
"""
import whisper
import os
from typing import Optional

# Load Whisper model (small model for faster processing)
_model_cache = None

def get_whisper_model():
    """Get or load Whisper model (cached)"""
    global _model_cache
    if _model_cache is None:
        # Using 'base' model for balance between speed and accuracy
        _model_cache = whisper.load_model("base")
    return _model_cache

async def transcribe_audio(audio_path: str) -> str:
    """
    Transcribe audio file to text using Whisper
    """
    try:
        model = get_whisper_model()
        result = model.transcribe(audio_path)
        return result["text"].strip()
    except Exception as e:
        raise Exception(f"Error transcribing audio: {str(e)}")

