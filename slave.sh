sudo apt-get update
sudo apt install openjdk-17-jre -y 
sudo apt install docker.io -y
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock
hostname slave
exec bash