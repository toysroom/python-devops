pipeline {
    agent any
    environment {
        ACR_LOGIN_SERVER = 'flaskacr12345.azurecr.io'
    }
    stages {
        stage('Clone repo') {
            steps {
                sh 'pwd'
                git branch: 'main', url: 'https://github.com/toysroom/python-devops.git'
                sh 'ls -la'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'pwd'
                sh 'whoami'
                sh 'docker build -t flask-api .'
            }
        }
        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: '85c7ecb9-125d-429d-bc12-380a6f79aa4a', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
                    sh 'docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME -p $ACR_PASSWORD'
                }
            }
        }
        stage('Push to ACR') {
            steps {
                sh 'docker tag flask-api $ACR_LOGIN_SERVER/flask-api:latest'
                sh 'docker push $ACR_LOGIN_SERVER/flask-api:latest'
            }
        }
        stage('Deploy to Azure App Service') {
            steps {
                withCredentials([azureServicePrincipal('b1117f31-b4d7-4a67-8207-4b8742f03c18')]) {
                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                    sh 'az account show' 
                    sh 'az account set --subscription $AZURE_SUBSCRIPTION_ID'
                    sh 'az webapp config container set --name flask-app12345 --resource-group flask-rg --docker-custom-image-name $ACR_LOGIN_SERVER/flask-api:latest'
                    sh 'az webapp restart --name flask-app12345 --resource-group flask-rg'
                }
            }
        }
    }
}
