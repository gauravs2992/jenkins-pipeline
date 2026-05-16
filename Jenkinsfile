#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-2"
    }
    
    stages {
        stage('Install Terraform') {
    agent any
    when {
        not {
            expression {
                return sh(script: 'command -v terraform >/dev/null 2>&1', returnStatus: true) == 0
            }
        }
    }
    steps {
        sh '''
            sudo apt update && sudo apt install -y curl gnupg software-properties-common
            curl -fsSL https://hashicorp.com | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install -y terraform
            terraform -v
        '''
    }
}
        stage("Create an EKS Cluster") {
            steps {
                script {
                    dir('2-terraform-eks-deployment') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
        stage("Deploy to EKS") {
            steps {
                script {
                    dir('kubernetes') {
                        sh "aws eks update-kubeconfig --name my-eks-cluster"
                        sh "kubectl apply -f nginx-deployment.yaml"
                        sh "kubectl apply -f nginx-service.yaml"
                    }
                }
            }
        }
    }
}
