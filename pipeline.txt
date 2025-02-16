**Create 3 EC2 instances :**

Jenkins - ID_jenkins
Sonar Qube -ID_SonarQube
Dockers - ID_Dockers

Note : All required security group ports/firewall to be open (8080 / 9000 / 80)

**Install Jenkins and connect to Github and SonarQube (pipeline)**

sudo apt update
sudo apt install openjdk-17-jre
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins


-----------------------------------------------------
Jenkins Web URL - http://ec2IP:8080/
User ID / PWD - admin/admin

Created a webhook in your Github account to send code changes to Jenkins. 
Click Settings - Webhook - Add webhook - https://jenkinsIP:8080/github-webhook/  (ensure tick in push and pull - update webhook)

Go to Jenkins website - 
Created a Freestyle project in Jenkins for pipeline (A10001pipeline).
(Any changes in Github triggers the pipeline)

**Install SonarQube and Configure on Jenkins (connect to pipeline)**

sudo apt update
sudo apt install openjdk-17-jre
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.1.0.102122.zip?_gl=1*w7u3a6*_gcl_au*NDQwODQxNjEuMTczODUwNzk2MA..*_ga*NTQzMzY5NjA4LjE3Mzg1MDc5NjA.*_ga_9JZ0GZ5TC6*MTczODUwNzk1OS4xLjEuMTczODUwODA2Ny41Ny4wLjA.

sudo apt install unzip 
unzip <zip file name>
./sonar.sh start
./sonar.sh console

visit Sonarqube URL -http://EC2IP:9000/
User Id : admin
Password : admin
Change the password on first login

Create a Project - Name is ID - Select Github - Others.
Note down the project Key - sonar.projectKey=Id

Click your user profile logo (on top right corner) - My account -Security - generate Token - give a name - type is Global - Click generate
Note down the long key as below (this is example):-
Security key token - sqa_0bd83a93e687e1cd1cfc1025e48fe51dff9d1b12

Code To paste in Jenkins (if needed) 
node {
  stage('SCM') {
    checkout scm
  }
  stage('SonarQube Analysis') {
    def scannerHome = tool 'SonarScanner';
    withSonarQubeEnv() {
      sh "${scannerHome}/bin/sonar-scanner"
    }
  }
}

On Jenkins website - 
Manage Jenkins Plugins - Install 4 plugins - Sonarqube scanner, SSH2easy, SSHServer, Docker, CloudBees Docker Build and Publish & SSH Agent
Under Manage jenkins - Tools (Global tool config) - SonarQube Scanner installations
Add sonarqube scanner - Just give a name and save
Under System configure tools - Sonarcube servers -Added sonarcube
Name : SonarQube and Given URL of sonarqube 
Server authentication -  Added - Jenkins   -  secret text (pasted security key as above from SonarQube)
select the pipeline we created-  Configure - BUILD STEPS - choosen Add build step - execute sonarqube scanner
Paste the Project key taken from SonarQube under the box Analysis properties & saved. 

Now Github - Jenkins - SonarQube Pipeline is running and make changes in Github index.html to see the changes in jenkins. Pipeline should trigger immediately on making any change to github code. 

**Install Dockers**

sudo apt-get 
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo docker --version
sudo docker run hello-world
sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker ubuntu

sudo vi /lib/systemd/system/docker.service
Find the line starting with ExecStart. Comment the existing line with # and add a new line as below:
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock
Restart 2 services - 
sudo systemctl daemon-reload 
sudo service docker restart
------------

**Integration Dockers to Jenkins**

Install docker in Jenkins EC2 also - (using this to build images) - Follow same steps as above. 
Then run this command - important - sudo usermod -aG docker ubuntu (OR) sudo usermod -aG docker $USER 
Go to Jenkins website -  Manage Jenkins - Tools - Configure Docker installation - give any name (docker- version latest - install automatically) - Save
Go to pipeline - configuration - Add a build step after Sonarqube - Select Docker build and push
 Repository Name : anilmidna/a10001 (this is docker hub repository name)
 Tag : latest
Registry credentials Click Add and create docker hub username and password credentials
Once done select it from drop down (very important)
Click the Advanced drop down - ensure we have tick in Force pull, Create fingerprints. , under Docker installation – select docker (same name we configured above step 2).
Move down and under Execute Shell (box) paste the below command : 

ssh -o StrictHostKeyChecking=no ubuntu@DOCKEREC2IP "
	echo 'Pulling latest Docker image...';
    docker pull abcdefg(dockerhub repo)/xyz:latest;
        echo 'Stopping and removing old container...';
    docker stop my-website || true;
    docker rm my-website || true;
        echo 'Starting new container...';
    docker run -d -p 80:80 --name my-website abcdefg(dockerhub repo)/xyz:latest;
        echo 'Deployment successful!';
"
Save

**Run the Jenkins pipeline**

Take the IP Address of Dockers EC2 and paste in a browser to see the contents of the index.html in GITHUB. Make changes to index.html in github and check if Jenkins pipeline runs automatically and Dockers website is showing the updated content. 

------------------------------------------------------------------------------
Note :    This is only for information - no action needed  - Build is based on Dockerfile in the Github repository :-

Basic nginx used Dockerfile (reference)
# Use the official Nginx image as a base
FROM nginx:1.25
# Copy the index.html file to the default Nginx web directory
COPY index.html /usr/share/nginx/html/
 # Expose port 80
EXPOSE 80
# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

