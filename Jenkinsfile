pipeline {
    agent any

    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['build', 'test', 'deploy'], description: 'Build action')
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
                withCredentials([string(credentialsId: '50d02dea-e285-43e0-892f-f4a52b2db82d', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('MySonarQube') {
                        script {
                            // Get Sonar Scanner path
                            def scannerHome = tool 'sonar_scanner'  // this name must match the one in Global Tool Config
                            sh """
                               ${scannerHome}/bin/sonar-scanner \\
                                -Dsonar.projectKey=myproject \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=http://65.2.30.107:9000 \
                                -Dsonar.login=$SONAR_TOKEN
                            """
                        }
                    }
                }
            }
        }
    }
}
