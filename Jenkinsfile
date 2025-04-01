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
                sh 'pwd'
                sh 'whoami'
                sh 'docker build -t flask-api .'
            }
        }
        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'b860d544-c335-45e5-9927-02b79fac275f', usernameVariable: 'ACR_USERNAME', passwordVariable: 'ACR_PASSWORD')]) {
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
                withCredentials([azureServicePrincipal('24d44371-bb86-4754-a344-9ab7396e1290')]) {
                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
                    sh 'az account show' 
                    sh 'az account set --subscription $AZURE_SUBSCRIPTION_ID'
                    sh 'az webapp config container set --name flask-app --resource-group flask-rg --docker-custom-image-name $ACR_LOGIN_SERVER/flask-api:latest'
                    sh 'az webapp restart --name flask-app --resource-group flask-rg'
                }
            }
        }
    }
}
