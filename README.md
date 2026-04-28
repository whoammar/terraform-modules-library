```markdown
# Terraform AWS Modular Infrastructure Repository

## 📌 Overview

This repository is a **production-grade Terraform modules library** designed to build scalable and reusable AWS infrastructure. It provides a **modular architecture approach** where each infrastructure component (VPC, EC2, S3, ECS) is independent, reusable, and production-ready.

**Why this repository exists:**

* ❌ Writing repeated Terraform code increases complexity
* ❌ Hardcoded infrastructure slows down scaling
* ❌ Managing multiple projects becomes inconsistent

**Solutions provided:**

* ✅ Reusable infrastructure modules
* ✅ Standardized AWS architecture patterns
* ✅ Faster deployment across multiple projects
* ✅ Clean separation of concerns
* ✅ Production-ready infrastructure design

---

## 🏗️ Architecture Flow

```
        ┌─────────────────────────────────────┐
        │         Terraform Modules           │
        │            Library                  │
        └─────────────┬───────────────────────┘
                      │
        ┌─────────────┴───────────────────────┐
        │                                     │
    ┌───▼───┐    ┌─────▼────┐    ┌─────────┐
    │  VPC  │    │   EC2    │    │   S3    │
    └───┬───┘    └─────┬────┘    └────┬────┘
        │              │              │
    ┌───▼───┐      ┌───▼───┐      ┌───▼───┐
    │Network│      │Compute│      │Storage│
    │Layer  │      │ Layer │      │ Layer │
    └───────┘      └───────┘      └───────┘
```

---

## 📁 Repository Structure

```
Terraform Modules Final/
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── ecs/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── projects/
│   ├── fargate-project/
│   ├── mendhak-project/
│   └── open-vpn-tunnel/
│
└── README.md
```

---

## 🧱 Available Modules

### 🌐 VPC Module
Creates a complete networking foundation.

* Multi-AZ VPC
* Public & Private Subnets
* NAT Gateway (optional)
* Route Tables
* Security Groups (EC2 & DB)

---

### 🖥️ EC2 Module
Reusable EC2 provisioning module.

* AMI-based instances
* Security group support
* User data scripts
* SSM optional support
* Environment tagging

---

### 🪣 S3 Module
Flexible S3 bucket management module.

* Private by default
* Static website hosting
* Versioning support
* Lifecycle rules
* Logging support
* Public access control options

---

### 🚀 ECS Fargate Module
Production-grade container orchestration module.

* Multi-service deployment (frontend/backend)
* ALB integration
* Path-based routing
* CloudWatch logging
* Autoscaling support
* Fully serverless containers (Fargate)

---

## ⚙️ Prerequisites

* Terraform ≥ 1.5
* AWS CLI configured
* IAM permissions for:

  * VPC
  * EC2
  * ECS
  * S3
  * ALB
  * IAM Roles
  * CloudWatch

---

## 🚀 Usage

### 1️⃣ Reference a Module

In your Terraform configuration:

```hcl
module "vpc" {
  source = "git@github.com:whoammar/terraform-modules-library.git//modules/vpc"

  vpc_name        = "prod-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
}
```

---

### 2️⃣ Deploy ECS Application

```hcl
module "ecs" {
  source = "git@github.com:whoammar/terraform-modules-library.git//modules/ecs"

  cluster_name    = "prod-cluster"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids

  services = {
    api = {
      image         = "mendhak/http-https-echo:40"
      port          = 8888
      cpu           = 256
      memory        = 512
      desired_count = 1

      path     = ["/api/*"]
      priority = 10
    }

    frontend = {
      image         = "nginx"
      port          = 80
      cpu           = 256
      memory        = 512
      desired_count = 1

      path     = ["/*"]
      priority = 20
    }
  }
}
```

---

### 3️⃣ Deploy EC2 Instance (Optional)

```hcl
module "ec2" {
  source = "git@github.com:whoammar/terraform-modules-library.git//modules/ec2"

  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]

  security_group_ids = [module.vpc.ec2_sg_id]
  instance_name      = "web-server"
}
```

---

### 4️⃣ Create S3 Bucket

```hcl
module "s3" {
  source = "git@github.com:whoammar/terraform-modules-library.git//modules/s3"

  bucket_name = "my-terraform-bucket"
  versioning  = true
  environment = "production"
}
```

---

## 🧠 Design Principles

* ✅ Reusability first
* ✅ Environment agnostic design
* ✅ Production-ready defaults
* ✅ Minimal hardcoding
* ✅ Secure-by-default architecture
* ✅ Modular dependency flow

---

## 🔐 Security Best Practices

* Private subnets for ECS workloads
* Security groups for controlled access
* ALB handles public traffic
* No direct exposure of backend services
* No secrets stored in repo
* Use AWS Secrets Manager or SSM Parameter Store

---

## 📦 Real Projects Using This Repo

* ✅ VPN Tunnel Infrastructure
* ✅ ECS Fargate Multi-tier Application
* ✅ Mendhak Debug Echo Service
* ✅ Static Website Hosting (S3)
* ✅ EC2-based workloads

---

## 🧹 Cleanup

To destroy infrastructure created with these modules:

```bash
terraform destroy
```

---

## ❗ Important Notes

* Never commit:

  * `.tfstate` files
  * `.tfvars` (if containing sensitive data)
* Always use remote backend (S3 + DynamoDB) in production
* Keep modules independent and reusable

---

## 🔮 Future Enhancements

* CloudFront CDN Module
* RDS Database Module
* ALB/NLB Standalone Module
* EKS Kubernetes Module
* CI/CD Terraform Pipeline (GitHub Actions)
* Monitoring with CloudWatch Dashboards

---

## 🤝 Contribution Guidelines

* Keep modules independent
* Avoid hardcoded values
* Follow variable-driven design
* Maintain documentation per module
* Test modules before submitting

---

## 👨‍💻 Author

**Muhammad Ammar**

---