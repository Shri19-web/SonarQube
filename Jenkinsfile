pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
  }

  environment {
    SONAR_TOKEN        = credentials('SONAR_TOKEN')        // Secret Text
    NEXUS_MAVEN        = credentials('NEXUS_MAVEN')        // Username + Password
    NEXUS_DOCKER       = credentials('NEXUS_DOCKER')       // Username + Password
    NEXUS_DOCKER_REPO  = '52.66.198.175:5000/docker_dev'   // Nexus Docker repo
    SONAR_HOST         = 'http://43.205.242.252:30201'     // SonarQube endpoint (no trailing slash)
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

    stage('Check SonarQube') {
      steps {
        echo 'Checking SonarQube availability...'
        sh 'curl -s --fail $SONAR_HOST/api/system/status || { echo "SonarQube is unreachable!"; exit 1; }'
      }
    }

    stage('SonarQube Scan') {
      steps {
        echo 'Running SonarQube scan...'
        withSonarQubeEnv('MySonar') {
          sh """
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=myproject \
              -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
              -Dsonar.login=$SONAR_TOKEN
          """
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo 'Waiting for SonarQube Quality Gate...'
        timeout(time: 20, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Fetch SonarQube Report') {
      steps {
        echo 'Fetching SonarQube analysis report...'
        script {
          // 1. Quality gate status
          sh """
            curl -s -u $SONAR_TOKEN: "$SONAR_HOST/api/qualitygates/project_status?projectKey=myproject" > sonar_quality_gate.json
          """

          // 2. Key metrics
          sh """
            curl -s -u $SONAR_TOKEN: "$SONAR_HOST/api/measures/component?component=myproject&metricKeys=bugs,vulnerabilities,code_smells,coverage,duplicated_lines_density,sqale_rating,reliability_rating,security_rating" > sonar_measures.json
          """

          // 3. Analysis history (for build mapping)
          sh """
            curl -s -u $SONAR_TOKEN: "$SONAR_HOST/api/project_analyses/search?project=myproject" > sonar_analyses.json
          """

          // Print summaries in Jenkins logs
          sh 'echo "--- Quality Gate ---"; cat sonar_quality_gate.json'
          sh 'echo "--- Measures ---"; cat sonar_measures.json'
          sh 'echo "--- Analyses ---"; cat sonar_analyses.json'

          // Archive artifacts for build record
          archiveArtifacts artifacts: 'sonar_*.json', followSymlinks: false
        }
      }
    }

    stage('Build & Package') {
      steps {
        echo 'Building the project...'
        sh 'mvn package -DskipTests'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }

    stage('Deploy Artifact to Nexus') {
      steps {
        echo 'Deploying artifact to Nexus...'
        withCredentials([usernamePassword(credentialsId: 'NEXUS_MAVEN', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          configFileProvider([configFile(fileId: '63f74aca-dc42-4dd8-98e0-f61960f5fc24', targetLocation: 'settings.xml')]) {
            sh """
              sed -i 's|<username>.*</username>|<username>$NEXUS_USER</username>|' settings.xml
              sed -i 's|<password>.*</password>|<password>$NEXUS_PASS</password>|' settings.xml
              mvn deploy -s settings.xml -DskipTests
            """
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo 'Building Docker image...'
        script {
          def image = "${env.NEXUS_DOCKER_REPO}/sonarqube-app:1.0.0-SNAPSHOT"
          sh "docker build -t ${image} ."
        }
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
        echo 'Pushing Docker image to Nexus...'
        withCredentials([usernamePassword(credentialsId: 'NEXUS_DOCKER', usernameVariable: 'NEXUS_DOCKER_USR', passwordVariable: 'NEXUS_DOCKER_PSW')]) {
          script {
            def image = "${env.NEXUS_DOCKER_REPO}/sonarqube-app:1.0.0-SNAPSHOT"
            def registry = env.NEXUS_DOCKER_REPO.split('/')[0]
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

  post {
    success {
      echo 'Full CI/CD pipeline succeeded.'
    }
    failure {
      echo 'Pipeline failed. Please check the logs.'
    }
  }
}
