provider "aws" {
    region = "us-east-1"
    #access_key = var.value_of_access
    #secret_key = var.value_of_secret
}

resource "aws_vpc" "test" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "test_vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.test.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.test.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "public2_subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.test.id
    cidr_block = "10.0.3.0/24"
    tags = {
        Name = "private_subnet"
    }
}

resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.test.id
    cidr_block = "10.0.4.0/24"
    tags = {
        Name = "private2_subnet"
    }
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.test.id
    tags = {
        Name = "IGW"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.test.id
    tags = {
        Name = "test_route"
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
}

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "test_sg" {
    name_prefix = "test_sg"
    description = "allow access to ec2"
    vpc_id = aws_vpc.test.id
    tags = {
        Name = "test_sg"
    }

    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = "3000"
        to_port = "9000"
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = "443"
        to_port = "443"
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = "4096"
}

resource "aws_key_pair" "test_key" {
    key_name = "test_key"
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "test_key" {
    filename = "test_key"
    content = tls_private_key.rsa.private_key_pem
}

resource "aws_ecr_repository" "ekart" {
    name = "ekart"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = "true"
    }
}

resource "aws_instance" "jenkins_master" {
    ami = var.ami
    instance_type = var.value_of_instance
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.test_sg.id]
    key_name = "test_key"
    associate_public_ip_address = "true"
    tags = {
        Name = "jenkins_master"
    }

    connection {
        type = "ssh"
        host = aws_instance.jenkins_master.public_ip
        user = "ubuntu"
        private_key = tls_private_key.rsa.private_key_openssh
    }

    provisioner "file" {
        source = "./jenkins.sh"
        destination = "/home/ubuntu/jenkins.sh"
    }

    provisioner "remote-exec" {
        inline = [ 
            "chmod +x /home/ubuntu/jenkins.sh",
            "sudo /home/ubuntu/jenkins.sh"
        ]
    }
}

resource "aws_instance" "jenkins_slave" {
    ami = var.ami
    instance_type = var.value_of_instance
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.test_sg.id]
    key_name = "test_key"
    associate_public_ip_address = "true"
    tags = {
        Name = "jenkins_slave"
    }

    connection {
        type = "ssh"
        host = aws_instance.jenkins_slave.public_ip
        user = "ubuntu"
        private_key = tls_private_key.rsa.private_key_openssh
    }

    provisioner "file" {
        source = "./slave.sh"
        destination = "/home/ubuntu/slave.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/slave.sh",
            "sudo /home/ubuntu/slave.sh"
        ]
    }
}

resource "aws_instance" "sonarqube" {
    ami = var.ami
    instance_type = var.value_of_instance
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.test_sg.id]
    key_name = "test_key"
    associate_public_ip_address = "true"
    tags = {
        Name = "sonarqube"
    }

    connection {
        type = "ssh"
        host = aws_instance.sonarqube.public_ip
        user = "ubuntu"
        private_key = tls_private_key.rsa.private_key_openssh
    }

    provisioner "file" {
        source = "./sonarqube.sh"
        destination = "/home/ubuntu/sonarqube.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/sonarqube.sh",
            "sudo /home/ubuntu/sonarqube.sh"
        ]
    }
}

resource "aws_instance" "nexus" {
    ami = var.ami
    instance_type = var.value_of_instance
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.test_sg.id]
    key_name = "test_key"
    associate_public_ip_address = "true"
    tags = {
        Name = "nexus"
    }

    connection {
        type = "ssh"
        host = aws_instance.nexus.public_ip
        user = "ubuntu"
        private_key = tls_private_key.rsa.private_key_openssh
    }

    provisioner "file" {
        source = "./nexus.sh"
        destination = "/home/ubuntu/nexus.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/nexus.sh",
            "sudo /home/ubuntu/nexus.sh"
        ]
    }
}

resource "aws_instance" "eks" {
    ami = var.ami
    instance_type = var.value_of_instance
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.test_sg.id]
    key_name = "test_key"
    associate_public_ip_address = "true"
    tags = {
        Name = "EKS"
    }

    connection {
        type = "ssh"
        host = aws_instance.eks.public_ip
        user = "ubuntu"
        private_key = tls_private_key.rsa.private_key_openssh
    }

    provisioner "file" {
        source = "./eks.sh"
        destination = "/home/ubuntu/eks.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/ubuntu/eks.sh",
            "sudo /home/ubuntu/eks.sh"
        ]
    }
}
