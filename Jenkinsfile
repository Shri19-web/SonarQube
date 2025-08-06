pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "3.110.215.133:5000"
        IMAGE_NAME = "docker-dev/myproject"
        SONAR_HOST_URL = "http://13.234.186.239:30200"
        SONAR_AUTH_TOKEN = credentials('sonarqube-token') // from Jenkins Credentials
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/Shri19-web/SonarQube.git', branch: 'main'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('MySonarQubeServer') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=myproject -Dsonar.projectName=myproject -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME:latest .'
                }
            }
        }

        stage('Push to Nexus Registry') {
            steps {
                script {
                    sh 'docker login $DOCKER_REGISTRY -u admin -p yourNexusPassword'  // Or use Jenkins credentials
                    sh 'docker tag $IMAGE_NAME:latest $DOCKER_REGISTRY/$IMAGE_NAME:latest'
                    sh 'docker push $DOCKER_REGISTRY/$IMAGE_NAME:latest'
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
        }
    }
}
