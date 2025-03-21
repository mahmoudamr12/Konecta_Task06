pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mahmoudamr/jenkins-image:latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    git credentialsId: 'github-credentials', url: 'https://github.com/mahmoudamr12/Konecta_Task06.git', branch: 'side'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    }
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                script {
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Production') { // Fixed typo
            steps {
                script {
                    sshagent(['ssh-to-prod']) {
                        withCredentials([string(credentialsId: 'prod-server-ip', variable: 'PROD_IP')]) {
                            sh '''
                            ssh -o StrictHostKeyChecking=no ubuntu@$PROD_IP << EOF
                                docker stop jenkins_container || true
                                docker rm jenkins_container || true
                                docker pull ${DOCKER_IMAGE}
                                docker run -d --name jenkins_container -p 8080:8080 ${DOCKER_IMAGE}
                            EOF
                            '''
                        }
                    }
                }
            }
        }
    } // Added missing closing bracket
}
