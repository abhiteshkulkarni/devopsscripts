pipeline{
    agent any
    stages{
        stage('Git-Clone'){
            steps{
                git 'https://github.com/abhiteshkulkarni/java-project-maven-new.git'
            }
        }
        stage('Compile') {
            steps{
                sh 'mvn compile'
            }
        }
        stage('Testing'){
            steps{
                sh 'mvn test'
            }
        }
        stage('Packaging'){
            steps{
                sh 'mvn clean package'
            }
        }
        stage('SonarQube Analysis'){
            steps{
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.7.0.1746:sonar'
                }
            }
        }
        stage('Artifacts'){
            steps{
                nexusArtifactUploader artifacts: [[artifactId: 'myapp', classifier: '', file: 'target/myapp.war', type: '.war']], credentialsId: 'nexus-creds', groupId: 'in.reyaz', nexusUrl: '43.205.242.9:8081/', nexusVersion: 'nexus3', protocol: 'http', repository: 'hotstar', version: '8.3.3-SNAPSHOT'
            }
        }
        stage('Artifacts to S3'){
            steps{
                s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'artifacts-s3-pvt-bkt', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: false, selectedRegion: 'ap-south-1', showDirectlyInBrowser: false, sourceFile: '**/*.war', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: true]], pluginFailureResultConstraint: 'FAILURE', profileName: 'S3-Creds', userMetadata: []
                }
        }
        stage('Deployment'){
            steps{
                deploy adapters: [tomcat9(credentialsId: 'Tomcat-Creds', path: '', url: 'http://13.233.96.42:8080/')], contextPath: '/tmp', war: '**/*.war'
            }
        }
    }
}
