pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mahmoudamr/jenkins-image2:latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script 
                {
                    // Detect if triggered by a pull request or merge
                    if (env.GITHUB_EVENT_NAME == 'pull_request') {
                        echo "Triggered by a Pull Request"
                        git credentialsId: 'github-credentials', url: 'https://github.com/mahmoudamr12/Konecta_Task06.git', branch: env.CHANGE_BRANCH
                    } else if (env.GITHUB_EVENT_NAME == 'push') {
                        echo "Triggered by a Push"
                        git credentialsId: 'github-credentials', url: 'https://github.com/mahmoudamr12/Konecta_Task06.git', branch: 'main'
                    } else {
                        error "Pipeline triggered by an unknown event: ${env.GITHUB_EVENT_NAME}"
                    }
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
                                # Add the user to the docker group
                                sudo usermod -aG docker ubuntu
                                # Apply the changes immediately
                                newgrp docker
                                docker ps -aq | xargs -r docker rm -f # delete all running containers
                                docker pull ${DOCKER_IMAGE}
                                
                                # Run the container
                                docker run -d --name prod_container -p 80:80 ${DOCKER_IMAGE}
                                docker ps
EOF
                            '''
                        }
                    }
                }
            }
        }
    }
}
