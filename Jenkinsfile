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
                                      -Dsonar.host.url=http://13.233.168.101:9000 \
                                      -Dsonar.login=<your-token>'
                }
            }
        }
    }
}
