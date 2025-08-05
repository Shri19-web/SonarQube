pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
  }

  environment {
    SONAR_TOKEN   = credentials('SONAR_TOKEN')     // Secret Text
    NEXUS_MAVEN   = credentials('nexus-maven')     // Username + Password
    NEXUS_DOCKER  = credentials('nexus-docker')    // Username + Password
    NEXUS_DOCKER_REPO = '13.126.160.215:5000/docker-dev'  // Replace with your Nexus Docker repo IP:port
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
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.BRANCH_NAME}"]],
          userRemoteConfigs: [[url: 'https://github.com/Shri19-web/SonarQube.git']]
        ])
      }
    }

    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv('MySonar') {
          sh '''
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=myproject \
              -Dsonar.host.url=http://13.126.160.215:30200/ \
              -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build & Package') {
      steps {
        sh 'mvn clean package'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }

    stage('Deploy Artifact to Nexus') {
      steps {
        sh """
          mvn deploy -s /var/jenkins_home/.m2/settings.xml \
            -DskipTests
        """
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def image = "${NEXUS_DOCKER_REPO}/hello-app:1.0"
          sh "docker build -t ${image} ."
        }
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
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
