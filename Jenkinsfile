pipeline {
    agent any

    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['build', 'test', 'deploy'], description: 'Build action')
    }

    tools {
        sonarQubeScanner 'SonarScanner'
    }
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
