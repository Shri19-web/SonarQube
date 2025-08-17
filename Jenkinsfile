pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
  }

  environment {
    APP_NAME           = 'sonarqube-app'
    APP_VERSION        = "1.0.0-${env.BUILD_NUMBER}"
    PROJECT_KEY        = 'myproject'
    IMAGE_TAG          = "${APP_NAME}:${APP_VERSION}"
    SONAR_TOKEN        = credentials('SONAR_TOKEN')       
    NEXUS_MAVEN        = credentials('NEXUS_MAVEN')
    NEXUS_DOCKER       = credentials('NEXUS_DOCKER')
    NEXUS_DOCKER_REPO  = 'http://13.234.32.98:5000/docker_dev'
    SONAR_HOST         = 'http://13.127.144.70:30201/'
  }

  parameters {
    string(name: 'BRANCH_NAME', defaultValue: 'Vidyashri.developer', description: 'Git branch to build')
  }

  triggers {
    githubPush()
  }

  stages {

    stage('Checkout Code') {
      steps {
        echo "Checking out branch: ${params.BRANCH_NAME}"
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.BRANCH_NAME}"]],
          userRemoteConfigs: [[url: 'https://github.com/Shri19-web/SonarQube.git']]
        ])
      }
    }

    stage('Set Commit Hash') {
      steps {
        script {
          env.GIT_COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          echo "Git Commit Hash: ${env.GIT_COMMIT_HASH}"
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo "Running SonarQube analysis..."
        sh """
          mvn clean verify sonar:sonar \
            -Dsonar.projectKey=${PROJECT_KEY} \
            -Dsonar.projectName=${APP_NAME} \
            -Dsonar.host.url=${SONAR_HOST} \
            -Dsonar.token=${SONAR_TOKEN} \
            -Dsonar.projectVersion=${BUILD_NUMBER}
        """
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 20, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Fetch SonarQube Report') {
      steps {
        script {
          def reports = [
            "quality_gate=qualitygates/project_status?projectKey=${PROJECT_KEY}",
            "measures=measures/component?component=${PROJECT_KEY}&metricKeys=bugs,vulnerabilities,code_smells,coverage,duplicated_lines_density,sqale_rating,reliability_rating,security_rating",
            "analyses=project_analyses/search?project=${PROJECT_KEY}"
          ]
          reports.each { entry ->
            def (name, endpoint) = entry.split('=')
            sh """
              curl -s -u ${SONAR_TOKEN}: "${SONAR_HOST}/api/${endpoint}" > sonar_${name}.json
            """
          }
          archiveArtifacts artifacts: 'sonar_*.json', followSymlinks: false
        }
      }
    }

    stage('Build & Package') {
      steps {
        sh 'mvn package -DskipTests'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }

    stage('Deploy Artifact to Nexus') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'NEXUS_MAVEN', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          configFileProvider([configFile(fileId: '63f74aca-dc42-4dd8-98e0-f61960f5fc24', targetLocation: 'settings.xml')]) {
            sh """
              mvn deploy -s settings.xml -DskipTests
            """
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def image = "${NEXUS_DOCKER_REPO}/${APP_NAME}:${APP_VERSION}-${GIT_COMMIT_HASH}"
          sh "docker build -t ${image} ."
        }
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'NEXUS_DOCKER', usernameVariable: 'NEXUS_DOCKER_USR', passwordVariable: 'NEXUS_DOCKER_PSW')]) {
          script {
            def image = "${NEXUS_DOCKER_REPO}/${APP_NAME}:${APP_VERSION}-${GIT_COMMIT_HASH}"
            def registry = env.NEXUS_DOCKER_REPO.split('/')[0]
            retry(2) {
              sh """
                echo "$NEXUS_DOCKER_PSW" | docker login http://${registry} -u "$NEXUS_DOCKER_USR" --password-stdin
                docker push ${image}
                docker logout http://${registry}
              """
            }
          }
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded for ${APP_NAME}:${APP_VERSION}-${GIT_COMMIT_HASH}"
    }
    failure {
      echo "Pipeline failed. Check logs."
      archiveArtifacts artifacts: 'sonar_*.json', allowEmptyArchive: true
    }
    always {
      echo "Build finished: ${currentBuild.currentResult}"
    }
  }
}
