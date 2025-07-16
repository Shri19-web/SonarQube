pipeline {
    agent any

    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['build', 'test', 'deploy'], description: 'Build action')
    }

    tools {
        sonarQubeScanner 'SonarScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Shri19-web/SonarQube.git'
            }
        }

        stage('Print Parameters') {
            steps {
                echo "Running in environment: ${params.ENV}"
                echo "Action selected: ${params.ACTION}"
            }
        }

        stage('SonarQube Analysis') {
            steps {
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
