# test_main.py
import pytest
from fastapi.testclient import TestClient
from app.main import app, perform_ocr
import io
from PIL import Image, ImageDraw, ImageFont

# Initialize the TestClient for your FastAPI application
client = TestClient(app)

# Helper function to create a mock image with text
def create_mock_image(text="Hello World"):
    """
    Creates a simple in-memory image with a given text.
    This is used to simulate an image upload for the OCR process.
    """
    # Create a new image with a white background
    img = Image.new('RGB', (300, 100), color='white')
    d = ImageDraw.Draw(img)
    
    # Try to use a common font, or fall back to default
    try:
        font = ImageFont.truetype("DejaVuSans.ttf", 30)
    except IOError:
        font = ImageFont.load_default()
        
    d.text((10, 10), text, fill=(0, 0, 0), font=font)
    
    # Save the image to a byte buffer
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    return buffer.getvalue()

def test_get_root():
    """
    Test the GET / endpoint to ensure it returns a successful status code
    and the correct content type.
    """
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers['content-type']

def test_perform_ocr_function():
    """
    Test the core OCR function directly with a mock image.
    This isolates the OCR logic from the FastAPI endpoint.
    """
    mock_image_data = create_mock_image()
    extracted_text = perform_ocr(mock_image_data)
    
    # Assert that the string is not empty after stripping whitespace
    assert extracted_text.strip()

def test_websocket_ocr_endpoint():
    """
    Test the WebSocket endpoint by sending a mock image and
    receiving the OCR result.
    """
    # Create a mock image with some text
    mock_image_data = create_mock_image("Some random text")
    
    # Use the TestClient to connect to the WebSocket endpoint
    with client.websocket_connect("/ws") as websocket:
        # Send the binary image data
        websocket.send_bytes(mock_image_data)
        
        # Receive the text result from the WebSocket
        extracted_text = websocket.receive_text()
        
        # Assert that the received text is not empty after stripping whitespace
        assert extracted_text.strip()

def test_websocket_disconnect():
    """
    Test a successful WebSocket connection and immediate disconnection.
    """
    # Using a with statement ensures the connection is closed properly
    with client.websocket_connect("/ws"):
        # The test passes if the connection is established and the context exits without error
        pass
