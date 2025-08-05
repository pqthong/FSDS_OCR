# main.py

import io
import asyncio
import pytesseract
import logging
from fastapi import FastAPI, WebSocket, Request, WebSocketDisconnect
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from fastapi.middleware.cors import CORSMiddleware
import redis.asyncio as redis
from PIL import Image

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = FastAPI(
    title="Tesseract OCR API",
    description="A simple OCR API with image caching using Pytesseract and Redis.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

redis_client = redis.Redis(host='redis', port=6379, db=0)

# Asynchronous OCR function to run in a separate thread
def perform_ocr(image_data):
    """
    Performs the OCR process on a given image using Pytesseract. This is a blocking function
    and will be run in a separate thread.
    """
    try:
        # Use Pillow to open the image from binary data
        img = Image.open(io.BytesIO(image_data))
        
        # Perform OCR using pytesseract
        extracted_text = pytesseract.image_to_string(img)
        print(f"OCR results: {extracted_text[:50]}...") # Print first 50 chars for log
        return extracted_text
    except Exception as e:
        logging.error(f"An unexpected error occurred during OCR: {e}")
        return f"Error during OCR: {e}"

# --- API Endpoints ---

@app.get("/", response_class=HTMLResponse)
async def get(request: Request):
    """
    Serves the main HTML page.
    """
    return templates.TemplateResponse("index.html", {"request": request})

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    Handles the real-time WebSocket connection for OCR.
    """
    await websocket.accept()
    logging.info("WebSocket connection accepted.")

    try:
        while True:
            # Receive image data from the client
            image_data = await websocket.receive_bytes()

            # Run the OCR process in a thread pool to avoid blocking the event loop
            text_result = await asyncio.to_thread(perform_ocr, image_data)
            
            # Send the OCR result back to the client
            await websocket.send_text(text_result)

    except WebSocketDisconnect:
        logging.info("Client disconnected.")
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        await websocket.close()

# Instructions to run the server:
# 1. Install dependencies: pip install "fastapi[all]" uvicorn pytesseract pillow
# 2. You DO need to install the Tesseract OCR engine on your system or in your Dockerfile.
# 3. Save this file as main.py in the project root.
# 4. Run the server with: uvicorn main:app --reload
