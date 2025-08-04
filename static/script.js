// static/script.js

document.addEventListener('DOMContentLoaded', () => {
    const video = document.getElementById('video');
    const canvas = document.getElementById('canvas');
    const resultBox = document.getElementById('result-box');
    const startStopButton = document.getElementById('startStopButton');
    const downloadButton = document.getElementById('downloadButton');
    const statusMessage = document.getElementById('statusMessage');
    
    // Modal elements for custom alerts
    const alertModal = document.getElementById('alert-modal');
    const alertMessage = document.getElementById('alert-message');
    const closeButton = document.querySelector('.close-button');

    let ws = null;
    let isOcrRunning = false;
    let animationFrameId = null;
    let lastSendTime = 0;
    // Limit OCR to roughly 1 frame per second (1000 ms)
    const sendInterval = 1000; 
    
    // --- Custom Alert Modal Logic ---
    function showAlert(message) {
        alertMessage.textContent = message;
        alertModal.style.display = 'flex';
    }

    function hideAlert() {
        alertModal.style.display = 'none';
    }

    closeButton.addEventListener('click', hideAlert);
    window.addEventListener('click', (event) => {
        if (event.target === alertModal) {
            hideAlert();
        }
    });

    // --- WebSocket Connection Logic ---
    function updateStatus(message, type = 'info') {
        statusMessage.textContent = message;
        statusMessage.className = `status-message ${type}`;
    }

    function connectWebSocket() {
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const wsUrl = `${protocol}//${window.location.host}/ws`;

        ws = new WebSocket(wsUrl);

        ws.onopen = async () => {
            updateStatus('Connected. Awaiting camera access.', 'success');
            
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
                video.srcObject = stream;
                
                // Once video is playing, enable the button
                video.addEventListener('loadeddata', () => {
                    startStopButton.disabled = false;
                    updateStatus('Camera ready. Click "Start OCR" to begin.', 'success');
                }, { once: true });
                
            } catch (err) {
                console.error('Could not access webcam:', err);
                updateStatus('Could not access webcam. Please check permissions.', 'error');
                showAlert('Error: Could not access webcam. Please ensure your browser has permission.');
                startStopButton.disabled = true;
            }
        };

        ws.onmessage = (event) => {
            resultBox.textContent = event.data;
            downloadButton.disabled = false;
        };

        ws.onclose = (event) => {
            console.warn('WebSocket disconnected:', event.code, event.reason);
            updateStatus('Disconnected. Attempting to reconnect...', 'info');
            startStopButton.disabled = true;
            startStopButton.textContent = 'Start OCR';
            isOcrRunning = false;
            if (animationFrameId) {
                cancelAnimationFrame(animationFrameId);
            }
            // Reconnect after a short delay
            setTimeout(connectWebSocket, 3000);
        };

        ws.onerror = (error) => {
            console.error('WebSocket error:', error);
            updateStatus('WebSocket error. See console for details.', 'error');
            // onclose will handle the reconnection
        };
    }
    
    // Start the connection on page load
    connectWebSocket();

    // --- Video Frame Processing and Sending ---
    startStopButton.addEventListener('click', () => {
        if (isOcrRunning) {
            // Stop the OCR process
            isOcrRunning = false;
            startStopButton.textContent = 'Start OCR';
            if (animationFrameId) {
                cancelAnimationFrame(animationFrameId);
            }
            updateStatus('OCR Stopped.', 'info');
        } else {
            // Start the OCR process
            isOcrRunning = true;
            startStopButton.textContent = 'Stop OCR';
            updateStatus('OCR running...', 'info');
            sendFrameLoop();
        }
    });

    function sendFrameLoop(timestamp) {
        if (!isOcrRunning || ws.readyState !== WebSocket.OPEN) {
            return;
        }

        // Rate limiter to prevent flooding the server
        if (timestamp - lastSendTime > sendInterval) {
            const context = canvas.getContext('2d');
            
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            canvas.toBlob((blob) => {
                if (blob) {
                    ws.send(blob);
                }
            }, 'image/jpeg', 0.8);

            lastSendTime = timestamp;
        }

        animationFrameId = requestAnimationFrame(sendFrameLoop);
    }
    
    // --- Download Functionality ---
    downloadButton.addEventListener('click', () => {
        const text = resultBox.textContent;
        if (!text || text === 'OCR results will appear here...' || text.startsWith('Error')) {
            showAlert('There is no text to download or an error occurred.');
            return;
        }
        const blob = new Blob([text], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'ocr_results.txt';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    });
});
