pipeline{
    agent{
         node{
             label "Slave-1"
             customWorkspace "/home/jenkins/boardgame"
         }
    }
    environment{
        JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
        PATH="$PATH:$JAVA_HOME/bin:/opt/apache-maven/bin"
    }
    parameters { 
        string(name: 'COMMIT_ID', defaultValue: '', description: 'Provide the Commit ID') 
        string(name: 'REPO_NAME', defaultValue: '', description: 'Provide the ECR Repository Name for Application Image')
        string(name: 'TAG_NAME', defaultValue: '', description: 'Provide the TAG Name')
    }
    stages{
        stage("Clone-Code"){
            steps{
                cleanWs()
                checkout scmGit(branches: [[name: '${COMMIT_ID}']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-cred', url: 'https://github.com/singhritesh85/Boardgame.git']])
            }
        }
        stage("SonarQube-Analysis"){
            steps{
                withSonarQubeEnv('SonarQube-Server') {
                    sh 'mvn clean install sonar:sonar'
                }
            }
        }
        stage("Quality Gate") {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
              }
            }
        }
        stage("Trivy Scan files"){
            steps{
                sh 'trivy fs . > /home/jenkins/trivy-filescan.txt'
            }
        }
        stage("Nexus-Artifact Upload"){
            steps{
                script{
                    def mavenPom = readMavenPom file: 'pom.xml'
                    def nexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "maven-snapshot" : "maven-release"
                    nexusArtifactUploader artifacts: [[artifactId: 'spring-boot-starter-parent', classifier: '', file: "target/database_service_project-${mavenPom.version}.jar", type: 'jar']], credentialsId: 'nexus', groupId: 'org.springframework.boot', nexusUrl: 'nexus.singhritesh85.com', nexusVersion: 'nexus3', protocol: 'https', repository: "${nexusRepoName}", version: "${mavenPom.version}"
                }
            }
        }
        stage("Docker Build"){
            steps{
                sh 'docker system prune -f --all'
                sh 'docker build -t ${REPO_NAME}:${TAG_NAME} .'
                sh 'trivy image --exit-code 0 --severity MEDIUM,HIGH ${REPO_NAME}:${TAG_NAME}'
                //sh 'trivy image  --exit-code 1 --severity CRITICAL ${REPO_NAME}:${TAG_NAME}'
                sh 'aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 027330342406.dkr.ecr.us-east-2.amazonaws.com'
                sh 'docker push ${REPO_NAME}:${TAG_NAME}'
            }
        }
        stage("Deployment"){
            steps{
                sh 'argocd login argocd.singhritesh85.com --username admin --password Dexter@123 --skip-test-tls  --grpc-web'
                sh 'argocd app create boardgame --project default --repo https://github.com/singhritesh85/helm-repo-for-ArgoCD.git --path ./folo --dest-namespace boardgame --dest-server https://kubernetes.default.svc --helm-set service.port=80 --helm-set image.repository=${REPO_NAME} --helm-set image.tag=${TAG_NAME} --helm-set replicaCount=2 --upsert'
                sh 'argocd app sync boardgame'
            }
        }
    }    
}
