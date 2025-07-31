pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQube-K8s'
    }

    stages {
        stage('Branch Filter') {
            when {
                expression { return env.BRANCH_NAME == 'Vidyashri.developer' }
            }
            steps {
                echo "Running on developer branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Scan') {
            when {
                expression { return env.BRANCH_NAME == 'Vidyashri.developer' }
            }
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh 'sonar-scanner -Dsonar.projectKey=MyApp -Dsonar.sources=.'
                }
            }
        }

        stage('Quality Gate') {
            when {
                expression { return env.BRANCH_NAME == 'Vidyashri.developer' }
            }
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build') {
            when {
                expression { return env.BRANCH_NAME == 'Vidyashri.developer' }
            }
            steps {
                sh 'mvn clean package'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
