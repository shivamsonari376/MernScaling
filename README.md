Full-Stack Deployment Guide

This document provides step-by-step instructions on deploying the MERN application using two different approaches:

EC2-Based Deployment (using AWS ALB, Target Groups, and EC2 Instances)

Kubernetes-Based Deployment (using Helm, EKS, and AWS ECR)

Additionally, it covers:

CI/CD Workflow

Database Backup Automation

Domain Configuration with Cloudflare

1️⃣ EC2-Based Deployment

Architecture Overview

Backend Instances: 2 EC2 instances running backend services (hello-service, profile-service).

Frontend Instance: A separate EC2 instance hosting the frontend.

Load Balancer: ALB with two target groups.

Cloudflare: Used to map domain (theshiv.xyz).

Deployment Steps

1. Build Docker Image & Push to ECR

# Build the Docker image
docker build -t myapp .

# Tag the image for AWS ECR
docker tag myapp:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

# Authenticate to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com

# Push to ECR
docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

2. Launch EC2 Instances & Install Docker

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

3. Run the Containers on EC2

# Pull the image from ECR
docker pull <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

# Run the container
docker run -d -p 3001:3001 --name hello-service <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

4. Configure Application Load Balancer (ALB)

Create an Application Load Balancer.

Add Target Groups:

hello-service (port 3001)

profile-service (port 3002)

Register EC2 instances with the Target Groups.

Set up an ALB Listener to route traffic.

5. Domain Setup with Cloudflare

Add an A record in Cloudflare to point theshiv.xyz to ALB DNS.

2️⃣ Kubernetes-Based Deployment

Architecture Overview

EKS Cluster with 3 worker nodes.

Helm Charts for automated deployments.

LoadBalancer Service for frontend.

ClusterIP Services for backend APIs.

Deployment Steps

1. Create an EKS Cluster

aws eks create-cluster --name my-eks-cluster --role-arn <iam_role_arn> --resources-vpc-config subnetIds=<subnet_ids>,securityGroupIds=<sg_ids>

2. Install Helm & Create Helm Chart

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Create a Helm Chart
helm create myapp

3. Define Kubernetes Resources

Modify templates/deployment.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-service
  template:
    metadata:
      labels:
        app: hello-service
    spec:
      containers:
        - name: hello-service
          image: <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest
          ports:
            - containerPort: 3001

4. Deploy to Kubernetes

helm install myapp ./myapp

5. Expose Application via LoadBalancer

Modify templates/service.yaml:

apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 3000
  selector:
    app: frontend

Apply changes:

kubectl apply -f templates/service.yaml

3️⃣ Database Backup Automation

Backup Script (mongodb_backup.sh)

#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_PATH="/home/ec2-user/mongodb_backups/mongodb_backup_$TIMESTAMP.gz"

mongodump --uri="mongodb+srv://shivamsonari376:RLiW8WDeLKttZBPn@cluster0.4grys.mongodb.net/mern" --db=mern --archive=$BACKUP_PATH --gzip

aws s3 cp $BACKUP_PATH s3://shivam-db-backups/mongodb-backups/
rm -f $BACKUP_PATH

Automating via Cron Job

crontab -e

Add the following line:

0 3 * * * /home/ec2-user/mongodb_backup.sh >> /home/ec2-user/backup.log 2>&1

(Runs every day at 3 AM)

4️⃣ CI/CD Workflow

GitHub Actions Workflow (.github/workflows/deploy.yml)# MernScaling
