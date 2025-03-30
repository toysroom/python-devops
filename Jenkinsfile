pipeline {
    agent any
    environment {
        ACR_LOGIN_SERVER = 'flaskacr12333.azurecr.io'
        ACR_USERNAME = credentials('acr-username') 
        ACR_PASSWORD = credentials('acr-password') 
    }
    stages {
        stage('Clone repo') {
            steps {
                git 'https://github.com/toysroom/python-devops.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t flask-api .'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'docker run --rm flask-api pytest'
            }
        }
        stage('Push to ACR') {
            steps {
                sh 'docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME -p $ACR_PASSWORD'
                sh 'docker tag flask-api $ACR_LOGIN_SERVER/flask-api:latest'
                sh 'docker push $ACR_LOGIN_SERVER/flask-api:latest'
            }
        }
        stage('Deploy to Azure App Service') {
            steps {
                sh 'az webapp config container set --name flask-app --resource-group flask-rg --docker-custom-image-name $ACR_LOGIN_SERVER/flask-api:latest'
                sh 'az webapp restart --name flask-app --resource-group flask-rg'
            }
        }
    }
}
