"""
Ollama AI client for generating BRD and TDD documents
"""
import asyncio
import requests
import json
import os

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
DEFAULT_MODEL = os.getenv("OLLAMA_MODEL", "llama3")

async def generate_with_ollama(prompt: str, model: str = None) -> str:
    """
    Generate text using Ollama LLM
    """
    if model is None:
        model = DEFAULT_MODEL
    
    url = f"{OLLAMA_BASE_URL}/api/generate"
    
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False
    }
    
    def _make_request():
        """Synchronous request function"""
        try:
            response = requests.post(url, json=payload, timeout=300)
            response.raise_for_status()
            result = response.json()
            return result.get("response", "")
        except requests.exceptions.ConnectionError as e:
            raise Exception(f"Cannot connect to Ollama at {url}. Make sure Ollama is running: {str(e)}")
        except requests.exceptions.Timeout as e:
            raise Exception(f"Ollama request timed out after 300 seconds: {str(e)}")
        except requests.exceptions.HTTPError as e:
            raise Exception(f"Ollama API HTTP error: {str(e)}")
        except requests.exceptions.RequestException as e:
            raise Exception(f"Ollama API error: {str(e)}")
        except Exception as e:
            raise Exception(f"Unexpected error calling Ollama: {str(e)}")
    
    try:
        # Run the synchronous request in a thread pool
        # Use get_running_loop() for Python 3.7+ which is safer in async context
        try:
            loop = asyncio.get_running_loop()
        except RuntimeError:
            # Fallback if no running loop
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        
        result = await loop.run_in_executor(None, _make_request)
        
        if not result or result.strip() == "":
            raise Exception("Ollama returned empty response. Check if the model is loaded correctly.")
        
        return result
    except Exception as e:
        # Re-raise with more context
        error_msg = str(e)
        if "Connection" in error_msg or "connect" in error_msg.lower():
            raise Exception(f"Cannot connect to Ollama at {OLLAMA_BASE_URL}. Please ensure Ollama is running: `ollama serve`")
        raise Exception(f"Error generating with Ollama: {error_msg}")

def load_prompt_template(template_name: str) -> str:
    """
    Load prompt template from prompts directory
    """
    template_path = os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        "prompts",
        f"{template_name}.txt"
    )
    
    if os.path.exists(template_path):
        with open(template_path, "r", encoding="utf-8") as f:
            return f.read()
    else:
        # Return default template if file doesn't exist
        return get_default_template(template_name)

def get_default_template(template_name: str) -> str:
    """Default templates if files don't exist"""
    templates = {
        "brd": """You are an expert Business Analyst with 15+ years of experience. Generate a comprehensive, client-ready Business Requirement Document (BRD) following the exact structure provided in the template file. 

The BRD must include:
- Tables for stakeholders, role capabilities, technology stack
- Emojis for visual appeal (📘, ✅, ❌)
- Architecture diagrams in text format
- Both business and technical aspects
- Professional formatting with proper markdown
- Comprehensive coverage of all sections

Client Input:
{input_text}

Generate a professional, detailed, client-ready BRD matching the template structure exactly. The document should be suitable for direct use in client presentations, sign-offs, and development planning.""",
        
        "tdd": """You are an expert Technical Architect. Generate a Technical Design Document (TDD) based on the following requirements.

Requirements:
{input_text}

Please generate a TDD with the following sections:
1. Architecture Overview
2. Module Design
3. Data Flow
4. API Summary
5. Technology Stack
6. Database Schema (if applicable)
7. Security Considerations

Make it technical, detailed, and implementation-ready.""",
        
        "feedback_update": """You are an expert Business Analyst. Update the following BRD based on client feedback.

Current BRD (Version {version}):
{current_brd}

Client Feedback:
{feedback}

Please generate an updated BRD (Version {new_version}) that incorporates the feedback while maintaining consistency with the original document. Highlight what changed."""
    }
    
    return templates.get(template_name, "")

