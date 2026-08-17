pipeline {

    agent any

    environment {
        APP_NAME = 'banking-system'
        IMAGE_NAME = 'banking-system'
        CONTAINER_NAME = 'banking-system'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                    -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                    -t ${IMAGE_NAME}:latest \
                    .
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    docker run -d \
                    --name ${CONTAINER_NAME} \
                    ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    sleep 5

                    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
                        echo "Deployment successful."
                    else
                        echo "Deployment failed."
                        exit 1
                    fi
                '''
            }
        }
    }

    post {

        success {
            echo 'BankingSystem deployment completed successfully.'
        }

        failure {
            echo 'BankingSystem pipeline failed.'
        }

        always {
            sh 'docker images ${IMAGE_NAME} || true'
        }
    }
}
