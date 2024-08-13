# Youtube Clone application Deployment, Static Code Testing, Monitoring, Notification Service.
**Tools Used**

- **Git**: Version control.
- **Github**: Code hosting and collaboration.
- **Terraform**: Cloud resource management (IaaC).
- **Docker**: Containerization.
- **SonarQube**: Code quality analysis.
- **Jenkins**: Continuous integration and deployment.
- **EKS**: Kubernetes orchestration on AWS.
- **Prometheus**: Monitoring and alerting.
- **Grafana**: Metrics visualization.
- **Trivy**: Container vulnerability scanning.


## Architecture

<p align="center">
  <img src="./Images/Project-Architecture.png" width="600" title="Architecture" alt="Architecture">
  </p>


# [A] Let's use Terraform to create an EC2 instance for Jenkins, Docker and SonarQube
**Resource Deployment**
1. Use Terraform to Launch EC2 Instance and service installation, Security Groups.
2. Dir[Jenkins-SonarQube] contains Terraform manifest files update accordingly.
```terraform
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
terraform destory
```

### Jenkins Configuration

**Install Jenkins plugins**
Eclipse Temurin installer, SonarQube Scanner, Sonar Quality Gates, Quality Gates, NodeJS, Docker, Docker Commons, Docker pipeline, Docker API, Docker Build steps, prometheus metrics, Kubernetes, Kubernetes Client API, Kubernetes Credentials, Kubernetes CLI.


**Jenkins Global Credentials:**

Add Credentials For SonarQube, Docker, Gmail. Kubernetes


**Manage Jenkins Tools**

Manage Jenkins Tools: NodeJS Installation, JDK installation, Docker and SonarScanner Installation



**Configure Email Notification Through Jenkins**

Manage Jenkins System and Setup Email Notification and Extended Notifications.



## Configure SonarQube and Integrate with Jenkins
**SonarQube Token Creation**

Sonar Qube Configuration: Initial ID password is admin. Then Create Authentication Token. name: token-for-jenkins. Copy 
the token and add in jenkins global credentials.

Manage Jenkins ==> System ==> SonarQube Installation ==> name: SonarQube-Server ==> ServerURL: SonarQube Servers(http://PrivateIP:9000) ==> token: SonarQube-Token


SonarQube ==> Quality Gate ==> Create ==> SonarQube-Quality-Gate

SonarQube ==> Administration ==> General Settings Webhooks ==> Create Webhook ==> name: jenkins ==> URL: jenkins(http://PrivateIP:8080)/sonarqube-webhook/


SonarQube ==> Create a Project ==> Project display name: Youtube-CICD ==> project key: Youtube-CICD ==> Setup.

SonarQube ==> Locally ==> Provide Token ==> Token name: Analyze "Youtube-CICD" ==> Generate. ==> Continue ==> Other ==> Linux. (Copy the code)



**Create and Run Jenkins Job till 'TRIVY FS SCAN'**


**Add Docker Push Image phase in Jenkins Pipeline and Trivy Phase**


# [B] Terraform to Create EC2 Instance and Setup Prometheus & Grafana
1. Use Terraform to Launch EC2 Instance and service installation, Security Groups.
2. Dir[Prometheus-Grafana] contains Terraform manifest files update accordingly.

**Commands to check Installed services**
```bash
sudo systemctl status prometheus
sudo systemctl status node_exporter
sudo systemctl status grafana-server
```

**Add job for node exporter in prometheus**
```bash
sudo nano /etc/prometheus/prometheus.yml 
```
and below the job of prometheus, add job for node exporter
```
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['Monitoring server Public IP:9100']

```
Check the indentatio of the prometheus config file with below command
```bash
promtool check config /etc/prometheus/prometheus.yml
```
Reload the Prometheus configuration
```bash
curl -X POST http://localhost:9090/-/reload
```


Login into Grafana and add Prometheus.(node Exporter) 

Connection ==> Data Soruce ==> Prometheus and add http://grafana-publicIP:9090 then save and test.

Import Dashboard ==> 1860

Manage Jenkins: Prometheus and add build parameter, add build status.


**On monitoring server add job for Jenkins**
```bash
sudo nano /etc/prometheus/prometheus.yml
```
```
  - job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['Jenkins Public IP:8080']
```
Check the indentatio of the prometheus config file with below command
```bash
promtool check config /etc/prometheus/prometheus.yml
```
Reload the Prometheus configuration
```bash
curl -X POST http://localhost:9090/-/reload
```

**Jenkins Job Dashboard**

Import Dashboard ==> 9964


## [C] Create AWS EKS Cluster
1. Install kubectl on Jenkins Server
```bash
sudo apt update
sudo apt install curl
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```
2. Install AWS Cli
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```
3. Installing eksctl
```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
cd /tmp
sudo mv /tmp/eksctl /bin
eksctl version
```
4. Setup Kubernetes using eksctl
```bash
eksctl create cluster --name Virtualtechbox-cluster \
--region us-east-1 \
--node-type t2.small \
--nodes 3 \
--zones=us-east-1a,us-east-1b \
--node-zones=us-east-1a,us-east-1b \
```
5. Verify Cluster with below command
```bash
kubectl get nodes
```



## [D] Integrate Prometheus with EKS and Import Grafana Monitoring Dashboard for Kubernetes
1. Install Helm
```bash
sudo snap install helm --classic
helm version
```
                   OR
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
```

2. Install Prometheus on EKS
```bash
helm repo add stable https://charts.helm.sh/stable          ///We need to add the Helm Stable Charts for our local client

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts     ///Add Prometheus Helm repo

kubectl create namespace prometheus            ///Create Prometheus namespace

helm install stable prometheus-community/kube-prometheus-stack -n prometheus      ///Install Prometheus

kubectl get pods -n prometheus          ///To check whether Prometheus is installed

kubectl get svc -n prometheus           ///to check the services file (svc) of the Prometheus
```

##let’s expose Prometheus to the external world using LoadBalancer
```bash
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus    ///type:LoadBalancer, change port & targetport to 9090, save and close

kubectl get svc -n prometheus    //copy dns name of LB and browse with 9090
```

Go to Grafana and Add Data Source.

Name: Prometheus-EKS ==> URL: http://DNS-of-LB:9090 ==> save.

Import Dashboard ==> 15760 ==> DATA Source prometheus: Prometheus-EKS

Import Dashboard ==> 17119 ==> DATA Source prometheus: Prometheus-EKS




## [E] Configure the Jenkins Pipeline to Deploy

After setting up kubernetes Credentials Add Kubernetes Deployment Stage in Jenkins Pipeline update as required and Run the job.


## [F] Set the Trigger and Verify the CI/CD Pipeline

**Update Jenkins Job Configuration to allow Github Trigger Pooling**

**Add Webhook in Github**

**Now Whenever a push in made in main branch jenkinspipeline will be triggered**

## Pipeline Stages

<p align="center">
  <img src="./Images/Jenkins-Pipeline-View.png" width="600" title="Pipeline" alt="Pipeline">
  </p>