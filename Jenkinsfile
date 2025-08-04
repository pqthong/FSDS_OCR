// Jenkinsfile

pipeline {
    agent any

    environment {
        // Name for our Docker image. We use the build number as a unique tag.
        IMAGE_NAME = "my-fastapi-ocr-app"
        TAG = "build-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning the repository..."
                // The 'checkout scm' step automatically clones the repository
                // that triggered the build.
                checkout scm
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Installing Python dependencies for testing..."
                    // We need all the new dependencies, plus the new websocket client
                    sh "pip install -r requirements.txt"
                    
                    echo "Running tests..."
                    // Execute pytest. The pipeline will fail if any test fails.
                    sh "pytest test_api.py"
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${TAG}"
                    // Build the Docker image using the updated Dockerfile
                    sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying the new image using docker-compose..."
                    // Pass the environment variables for the image name and tag
                    // docker-compose up will now start both the web and redis services
                    sh "docker-compose up -d --no-deps --build web"
                }
            }
        }
        
        stage('Smoke Test') {
            steps {
                script {
                    echo "Waiting for the new service to become available..."
                    // This is a crucial step to ensure the app is live before testing
                    sh "until curl --output /dev/null --silent --head --fail http://localhost:8000; do echo -n '.'; sleep 5; done"
                    echo "Service is up! Running smoke tests."

                    // Re-run the tests against the live service to confirm functionality
                    // We install the new dependencies here just in case the first `pip install` step was lost
                    sh "pip install pytest websockets Pillow"
                    sh "pytest test_api.py"
                }
            }
        }
    }
}
