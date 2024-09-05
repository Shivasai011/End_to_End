sudo apt-get update
hostname sonar
exec bash 
sudo apt install docker.io -y
sudo docker run -d -p 9000:9000 sonarqube:lts-community