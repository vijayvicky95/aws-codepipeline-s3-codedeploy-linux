


pipeline {
    agent any
    

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-token')
        SONAR_ORGANIZATION = 'anilmidna'
        SONAR_PROJECT_KEY = 'anilmidna_jenkins'
    }

    stages {
        
        stage('Code-Analysis') {
            steps {
                withSonarQubeEnv('SonarCloud') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
    -Dsonar.organization=anilmidna \
  -Dsonar.projectKey=anilmidna_jenkins \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonarcloud.io  '''
                }
            }
        }
       
        
      
       stage('Docker Build And Push') {
            steps {
                script {
                    docker.withRegistry('', 'docker-cred') {
                        def buildNumber = env.BUILD_NUMBER ?: '1'
                        def image = docker.build("anilmidna/a10001:latest")
                        image.push()
                    }
                }
            }
        }
    
       
        stage('Deploy To EC2') {
            steps {
                script {
                        sh 'docker rm -f $(docker ps -q) || true'
                        sh 'docker run -d -p 3000:3000 anilmidna/a10001:latest'
                        
                    
                }
            }
        }
        
}
}
