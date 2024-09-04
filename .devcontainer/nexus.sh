sudo apt-get update
sudo apt install docker.io -y
sudo docker run -d -p 9091:9091 sonatype/nexus3
