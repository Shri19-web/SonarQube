pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Shri19-web/SonarQube.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQube') {
                    sh 'sonar-scanner -Dsonar.projectKey=my-project \
                                      -Dsonar.sources=. \
                                      -Dsonar.host.url=http://<sonarqube-ip>:9000 \
                                      -Dsonar.login=<your-token>'
                }
            }
        }
    }
}
