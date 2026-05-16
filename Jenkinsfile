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

        stage('Install AWS CLI') {
            when {
                not {
                    expression {
                        return sh(script: 'command -v aws >/dev/null 2>&1', returnStatus: true) == 0
                    }
                }
            }
            steps {
                sh '''
                    sudo apt-get update && sudo apt-get install -y unzip curl
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip awscliv2.zip
                    sudo ./aws/install
                    aws --version
                '''
            }
        }

        stage('Configure Kubeconfig') {
    steps {
        script {
            // Ensure kubeconfig directory exists
            sh '''
                mkdir -p /var/lib/jenkins/.kube
                aws eks update-kubeconfig --name my-eks-cluster --region us-east-2 --kubeconfig /var/lib/jenkins/.kube/config
                export KUBECONFIG=/var/lib/jenkins/.kube/config
                echo "KUBECONFIG set to /var/lib/jenkins/.kube/config"
            '''
        }
    }
}


        stage('Install kubectl') {
            when {
                not {
                    expression {
                        return sh(script: 'command -v kubectl >/dev/null 2>&1', returnStatus: true) == 0
                    }
                }
            }
            steps {
                sh '''
                    curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                    sudo mv kubectl /usr/local/bin/
                    kubectl version --client
                '''
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
                        sh "kubectl apply -f nginx-deployment.yaml --validate=false"
                        sh "kubectl apply -f nginx-service.yaml --validate=false"
                    }
                }
            }
        }
    }
}
