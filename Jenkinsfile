


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
       
        
      
    //    stage('Docker Build And Push') {
    //         steps {
    //             script {
    //                 docker.withRegistry('', 'docker-cred') {
    //                     def buildNumber = env.BUILD_NUMBER ?: '1'
    //                     def image = docker.build("anilmidna/a10001:latest")
    //                     image.push()
    //                 }
    //             }
    //         }
    //     }

        stage('Docker Build And Push') {
            steps {
                script {
                    docker.withRegistry('https://hub.docker.com', 'docker-cred') {
                        def buildNumber = env.BUILD_NUMBER ?: '1'
                        def imageName = "anilmidna/a10001:${buildNumber}"
                        def latestImage = "anilmidna/a10001:latest"

                        // Build Docker image
                        sh "docker build -t ${imageName} -t ${latestImage} ."

                        // Push both versioned and latest tag
                        sh "docker push ${imageName}"
                        sh "docker push ${latestImage}"
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
