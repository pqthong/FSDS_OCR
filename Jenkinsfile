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
        stage('Install Python Dependencies') {
            steps {
                script {
                    // Create a virtual environment named 'venv'
                    echo 'Creating Python virtual environment...'
                    sh 'python3 -m venv venv'
                    
                    // Activate the virtual environment
                    // The 'source' command is specific to bash.
                    // The `venv/bin/pip` approach works without activation.
                    // For Jenkins, we can just use the full path to the executables.
                    echo 'Installing dependencies from requirements.txt...'
                    sh 'venv/bin/pip install -r requirements.txt'
                    
                    // After this step, all subsequent Python commands should
                    // use the virtual environment's executables.
                    // For example, to run a test script:
                    // sh 'venv/bin/python your_test_script.py'
                }
            }
        }
        stage('Test') {
            steps {
                script {                
                    echo "Running tests..."
                    // Execute pytest. The pipeline will fail if any test fails.
                    sh "venv/bin/pytest test_api.py"
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
