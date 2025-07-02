- APP
- Dockerfile
- Jenkinsfile
- repository github

AZURE

- installazione az cli
- az login (az login --tenant <tenant-id>)
- creo resource group (az group create --name flask-rg --location italynorth)
- creo container registry nel resource group (az acr create --resource-group flask-rg --name flaskacr1234565 --sku Basic)
- creo VM x jenkins
    az vm create --resource-group flask-rg \
    --name jenkins-vm \
    --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
    --admin-username azureuser \
    --size Standard_B2s \
    --public-ip-sku Standard \
    --generate-ssh-keys

- login ssh (ssh -i ~/.ssh/id_rsa azureuser@<public_ip>)
- installo docker 
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

- esco, rientro, e verifico docker (docker --version)
- nella vm creo container di jenkins
docker run -d \
--name jenkins \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
--group-add $(stat -c '%g' /var/run/docker.sock) \
jenkins/jenkins:lts

- docker ps
- sbloccare SG sulla porta 8080 in ingresso
- http://<IP-VM>:8080
- sblocco jenkins - docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword 
- installare plugin (locale, pipeline, git, docker)
- ($ sudo usermod -aG docker $USER)

- entro nel container come root 
    docker exec -it --user root jenkins bash
- dentro al container 
    apt update
    apt install -y docker.io

- az acr update -n flaskacr1234565 --admin-enabled true
- az acr credential show --name flaskacr1234565 
- Login to ACR
- Push to ACR


- az appservice plan create --name flask-appservice-plan --resource-group flask-rg --is-linux --sku B1

- az webapp create --name flask-app1234565 --resource-group flask-rg --plan flask-appservice-plan --deployment-container-image-name flaskacr1234565.azurecr.io/flask-api:1.0

- in jenkins aggiungre plugin azure credentials, azure cli

- creare role su azure
    az ad sp create-for-rbac

    az role assignment create --assignee <appId> --role Contributor --scope /subscriptions/<subscriptionid>

installare az-cli nel container jenkins

- entro nel container come root 
    docker exec -it --user root jenkins bash
nel container
    apt update
    apt install -y azure-cli


dentro jenkins creare azureServicePrincipal

TRIGGER github
installare plugin github e abilitare trigger github nel job







Terraform crea:
    Resource Group
    ACR
    VM con IP pubblico
    App Service Plan + Web App

Ansible:
    Si connette alla VM via SSH
    Installa Docker e Jenkins
    Configura Jenkins (opzionale: installa plugin, crea job, ecc.)


TERRAFORM

brew tap hashicorp/tap

brew install hashicorp/tap/terraform

terraform -v


az ad sp create-for-rbac
az role assignment create --assignee <appId> --role Contributor --scope /subscriptions/<subscriptionid>

terraform init

terraform plan

terraform apply
terraform apply -auto-approve




ANSIBLE

brew install ansible

ansible --version

ansible-playbook -i inventory_file playbook.yml