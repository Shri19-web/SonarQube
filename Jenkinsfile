pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Shri19-web/SonarQube.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') {
                        sh '''
                          sonar-scanner \
                          -Dsonar.projectKey=myproject \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://65.2.30.107:9000 \
                          -Dsonar.login=$MySonarQube
                        '''
                    }
                }
            }
        }
    }
}
