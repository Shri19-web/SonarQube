pipeline {
    agent any
    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['build', 'test', 'deploy'], description: 'Build action')
    }
    tools {
        sonarQubeScanner 'MySonarScanner'
    }
    environment {
        SONAR_PROJECT_KEY = 'my-project'
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
                withSonarQubeEnv('MySonar') {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://65.2.30.107:9000 \
                          -Dsonar.login=0173e7db-1474-4208-9098-86c7cec00dd9
                    """
                }
            }
        }
    }
}
