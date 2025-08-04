# Dockerfile

# Use a robust Python base image that includes most necessary libraries
FROM python:3.10

# Set the working directory inside the container
WORKDIR /app

# Install Tesseract and its English language data
# This is a key step to provide the underlying OCR engine
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file and install the Python dependencies
# This allows Docker to cache this layer if requirements.txt doesn't change
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all the application files into the container
COPY . .

# Expose the port that the application will listen on
EXPOSE 8000

# Define the command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
