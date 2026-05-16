#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = "us-east-2"
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['create', 'destroy'],
            description: 'Choose whether to create or destroy the EKS cluster'
        )
    }

    stages {
        stage('Install Terraform') {
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
                    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                    sudo apt update && sudo apt install -y terraform
                    terraform -v
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -reconfigure'
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                script {
                    dir('2-terraform-eks-deployment') {
                        if (params.ACTION == 'create') {
                            sh "terraform apply -auto-approve"
                        } else if (params.ACTION == 'destroy') {
                            sh "terraform destroy -auto-approve"
                        }
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            when {
                expression { params.ACTION == 'create' }
            }
            steps {
                script {
                    dir('kubernetes') {
                        sh "aws eks update-kubeconfig --name my-eks-cluster --region us-east-2"
                        sh "kubectl apply -f nginx-deployment.yaml"
                        sh "kubectl apply -f nginx-service.yaml"
                    }
                }
            }
        }
    }
}
