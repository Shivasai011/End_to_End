sudo apt-get update
hostname nexus
exec bash 
sudo apt install docker.io -y
sudo docker run -d -p 8081:8081 sonatype/nexus3