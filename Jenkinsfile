pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
  }

  environment {
    SONAR_TOKEN        = credentials('SONAR_TOKEN')     // Secret Text
    NEXUS_MAVEN        = credentials('NEXUS_MAVEN')     // Username + Password
    NEXUS_DOCKER       = credentials('NEXUS_DOCKER')    // Username + Password
    NEXUS_DOCKER_REPO  = '13.126.160.215:5000/docker-dev'
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
        echo "📥 Checking out branch: ${params.BRANCH_NAME}"
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.BRANCH_NAME}"]],
          userRemoteConfigs: [[url: 'https://github.com/Shri19-web/SonarQube.git']]
        ])
      }
    }

    stage('Check SonarQube') {
      steps {
        echo '🔍 Verifying SonarQube server availability...'
        sh 'curl -s --fail http://3.6.94.147:30200/ > /dev/null || { echo "❌ SonarQube is not reachable!"; exit 1; }'
      }
    }

    stage('SonarQube Scan') {
      steps {
        echo '🚀 Running SonarQube Scan...'
        withSonarQubeEnv('MySonar') {
          sh '''
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=myproject \
              -Dsonar.host.url=http://15.206.189.87:30200/ \
              -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo '🚦 Waiting for SonarQube Quality Gate result...'
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build & Package') {
      steps {
        echo '📦 Building project and generating artifact...'
        sh 'mvn clean package'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }

    stage('Deploy Artifact to Nexus') {
      steps {
        echo '📤 Uploading artifact to Nexus Maven repo...'
        configFileProvider([configFile(fileId: '63f74aca-dc42-4dd8-98e0-f61960f5fc24', targetLocation: 'settings.xml')]) {
          sh 'mvn deploy -s settings.xml -DskipTests'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo '🐳 Building Docker image...'
        script {
          def image = "${NEXUS_DOCKER_REPO}/hello-app:1.0"
          sh "docker build -t ${image} ."
        }
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
        echo '📦 Pushing Docker image to Nexus...'
        script {
          def image = "${NEXUS_DOCKER_REPO}/hello-app:1.0"
          sh """
            echo "$NEXUS_DOCKER_PSW" | docker login $NEXUS_DOCKER_REPO -u "$NEXUS_DOCKER_USR" --password-stdin
            docker push ${image}
          """
        }
      }
    }
  }

  post {
    success {
      echo '✅ Full CI/CD pipeline successful.'
    }
    failure {
      echo '❌ Pipeline failed.'
    }
  }
}
