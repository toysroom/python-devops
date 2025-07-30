pipeline {
    agent any
    
    environment {
        ACR_LOGIN_SERVER = '330057236767.dkr.ecr.eu-central-1.amazonaws.com/flaskacr123456789-aws'
    }
    
    stages {
        stage('Clone repo') {
            steps {
                sh 'pwd'
                git branch: 'main', url: 'https://github.com/toysroom/python-devops.git'
                sh 'ls -la'
            }
        }

        // Stage test ....

        stage('Build Docker Image') {
            steps {
                sh 'pwd'
                sh 'whoami'
                sh 'docker build -t flask-api:1.0 .'
            }
        }
        
        stage('Login to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-ecr-creds', usernameVariable: 'ECR_USERNAME', passwordVariable: 'ECR_PASSWORD')]) {
                    sh 'docker login $ACR_LOGIN_SERVER -u $ECR_USERNAME -p $ECR_PASSWORD'
                }
            }
        }
        
        // stage('Push to ACR') {
        //     steps {
        //         sh 'docker tag flask-api:1.0 $ACR_LOGIN_SERVER/flask-api:1.0'
        //         sh 'docker push $ACR_LOGIN_SERVER/flask-api:1.0'
        //     }
        // }

        // stage('Deploy to Azure App Service') {
        //     steps {
        //         withCredentials([azureServicePrincipal('azure-service-principal')]) {
        //             sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
        //             sh 'az account show' 
        //             sh 'az account set --subscription $AZURE_SUBSCRIPTION_ID'
        //             sh 'az webapp config container set --name flask-app1234565 --resource-group flask-rg --docker-custom-image-name $ACR_LOGIN_SERVER/flask-api:1.0'
        //             sh 'az webapp restart --name flask-app1234565 --resource-group flask-rg'
        //         }
        //     }
        // }
    }

    // post {
    //     success {
    //         echo 'OK'
    //         mail to: 'alessandro.brugioni@gmail.com',
    //             subject: "Build Success: ${currentBuild.fullDisplayName}.",
    //             body: "The build was successful! Check the logs here: ${env.BUILD_URL}"
    //     }

    //     failure {
    //         echo 'KO'
    //         mail to: 'alessandro.brugioni@gmail.com',
    //             subject: "Build failed: ${currentBuild.fullDisplayName}",
    //             body: "The build was failed!. Check the logs here: ${env.BUILD_URL}"
    //     }
    // }
}
