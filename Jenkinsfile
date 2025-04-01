pipeline {
    agent any
    environment {
        ACR_LOGIN_SERVER = 'flaskacr12333.azurecr.io'
    }
    stages {
        stage('Clone repo') {
            steps {
                sh 'pwd'  // Mostra la directory attuale
                git branch: 'main', url: 'https://github.com/toysroom/python-devops.git'
                sh 'ls -la'  // Controlla se i file sono stati clonati
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t flask-api .'
            }
        }
        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
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
                sh 'az webapp config container set --name flask-app --resource-group flask-rg --docker-custom-image-name $ACR_LOGIN_SERVER/flask-api:latest'
                sh 'az webapp restart --name flask-app --resource-group flask-rg'
            }
        }
    }
}
