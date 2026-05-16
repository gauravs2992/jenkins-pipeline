module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.0"
    cluster_name = "my-eks-cluster"
    cluster_version = "1.29"

    cluster_endpoint_public_access  = true

    vpc_id = module.my-vpc.vpc_id
    subnet_ids = module.my-vpc.private_subnets

    tags = {
        environment = "development"
        application = "nginx-app"
    }

    eks_managed_node_groups = {
        dev = {
            min_size = 1
            max_size = 3
            desired_size = 2

            instance_types = ["t2.micro"]
            # Explicitly set the AMI type to avoid unsupported errors
            ami_type = "AL2_x86_64"   # Amazon Linux 2 EKS-optimized AMI
            # Other valid options: "AL2_x86_64_GPU", "BOTTLEROCKET_x86_64"
        }
    }
}
