pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mahmoudamr/jenkins-image2:latest"
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

        stage('Deploy to Production') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'prod-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                        withCredentials([string(credentialsId: 'prod-server-ip', variable: 'PROD_IP')]) {
                            sh '''
                            ssh -i $SSH_KEY -o StrictHostKeyChecking=no ubuntu@$PROD_IP << EOF
                                docker rm -f $(docker ps -aq)
                                docker pull ${DOCKER_IMAGE}
                                docker run -d --name prod_container -p 8080:8080 ${DOCKER_IMAGE}
                            EOF
                            '''
                        }
                    }
                }
            }
        }
    } // Correctly closes "stages" block
} // Correctly closes "pipeline" block
