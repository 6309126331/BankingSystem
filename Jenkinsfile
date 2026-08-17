pipeline {

    agent any

    environment {
        IMAGE_NAME = 'banking-system'
        CONTAINER_NAME = 'banking-system'
        DEPLOY_DIR = '/opt/banking-system'
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
                    mkdir -p ${DEPLOY_DIR}

                    CURRENT_IMAGE=$(docker inspect \
                        -f '{{.Config.Image}}' \
                        ${CONTAINER_NAME} 2>/dev/null || true)

                    echo "${CURRENT_IMAGE}" > ${DEPLOY_DIR}/previous-image

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
                    echo "Waiting for application to start..."
                    sleep 10

                    STATUS=$(docker inspect \
                        -f '{{.State.Status}}' \
                        ${CONTAINER_NAME} 2>/dev/null || echo "missing")

                    echo "Container status: ${STATUS}"

                    if [ "$STATUS" = "running" ]; then
                        echo "Deployment verification successful."
                    else
                        echo "Deployment verification failed."

                        echo "Container logs:"
                        docker logs ${CONTAINER_NAME} || true

                        exit 1
                    fi
                '''
            }
        }
    }

    post {

        success {
            echo 'BankingSystem CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'Deployment failed. Starting rollback.'

            sh '''
                if [ -f ${DEPLOY_DIR}/previous-image ]; then

                    PREVIOUS_IMAGE=$(cat ${DEPLOY_DIR}/previous-image)

                    if [ -n "$PREVIOUS_IMAGE" ]; then

                        echo "Previous image: ${PREVIOUS_IMAGE}"
                        echo "Rolling back..."

                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true

                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            ${PREVIOUS_IMAGE}

                        echo "Rollback completed."

                    else
                        echo "No previous image available."
                    fi

                else
                    echo "No rollback information available."
                fi
            '''
        }

        always {
            echo 'Docker images currently available:'

            sh '''
                docker images ${IMAGE_NAME} || true
            '''
        }
    }
}
