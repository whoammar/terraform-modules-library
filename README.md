````markdown
# 🚀 Terraform AWS Modular Infrastructure Repository

![Terraform](https://img.shields.io/badge/Terraform-v1.x-blue)
![AWS](https://img.shields.io/badge/AWS-Infrastructure-orange)
![Modules](https://img.shields.io/badge/Modules-Reusable-success)
![Architecture](https://img.shields.io/badge/Design-Modular-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)

---

# 📌 Repository Purpose

This repository is a **production-grade Terraform modules library** designed to build scalable and reusable AWS infrastructure.

It provides a **modular architecture approach** where each infrastructure component (VPC, EC2, S3, ECS) is independent, reusable, and production-ready.

---

# 🚀 Why This Repository Exists

In real-world cloud environments:

❌ Writing repeated Terraform code increases complexity  
❌ Hardcoded infrastructure slows down scaling  
❌ Managing multiple projects becomes inconsistent  

This repository solves these issues by introducing:

✔ Reusable infrastructure modules  
✔ Standardized AWS architecture patterns  
✔ Faster deployment across multiple projects  
✔ Clean separation of concerns  
✔ Production-ready infrastructure design  

---

# 🧱 Available Modules

## 🌐 VPC Module
Creates a complete networking foundation.

- Multi-AZ VPC
- Public & Private Subnets
- NAT Gateway (optional)
- Route Tables
- Security Groups (EC2 & DB)

---

## 🖥️ EC2 Module
Reusable EC2 provisioning module.

- AMI-based instances
- Security group support
- User data scripts
- SSM optional support
- Environment tagging

---

## 🪣 S3 Module
Flexible S3 bucket management module.

- Private by default
- Static website hosting
- Versioning support
- Lifecycle rules
- Logging support
- Public access control options

---

## 🚀 ECS Fargate Module
Production-grade container orchestration module.

- Multi-service deployment (frontend/backend)
- ALB integration
- Path-based routing
- CloudWatch logging
- Autoscaling support
- Fully serverless containers (Fargate)

---

# 🏗️ Repository Structure

```bash
.
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── s3/
│   └── ecs/
│
├── projects/
│   ├── vpn-tunnel/
│   ├── ecs-fargate-app/
│   ├── mendhak-debug-app/
│
└── README.md
````

---

# ⚙️ How This System Works

## 1️⃣ VPC (Foundation Layer)

All infrastructure starts from VPC:

* Defines networking (subnets, routing)
* Provides security boundaries
* Enables multi-AZ architecture

👉 All other modules depend on VPC outputs

---

## 2️⃣ Compute Layer (EC2 / ECS)

### EC2

Used for:

* Standalone servers
* Bastion hosts
* Simple applications

### ECS Fargate

Used for:

* Microservices
* Containerized applications
* Scalable multi-service architecture

👉 ECS integrates:

* ALB (traffic routing)
* CloudWatch (logging)
* Private subnets (security)

---

## 3️⃣ Storage Layer (S3)

Used for:

* Static websites
* File storage
* Logs
* Backups

---

# 🚀 Example Usage

## 📌 Step 1: Create VPC

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "prod-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
}
```

---

## 📌 Step 2: Deploy ECS Application

```hcl
module "ecs" {
  source = "./modules/ecs"

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

## 📌 Step 3: Deploy EC2 (Optional)

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = "ami-xxxxxx"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]

  security_group_ids = [module.vpc.ec2_sg_id]
}
```

---

# 🧠 Design Principles

✔ Reusability first
✔ Environment agnostic design
✔ Production-ready defaults
✔ Minimal hardcoding
✔ Secure-by-default architecture
✔ Modular dependency flow

---

# 🔐 Security Approach

* Private subnets for ECS workloads
* Security groups for controlled access
* ALB handles public traffic
* No direct exposure of backend services

---

# 📦 Real Projects Already Built Using This Repo

✔ VPN Tunnel Infrastructure
✔ ECS Fargate Multi-tier Application
✔ Mendhak Debug Echo Service
✔ Static Website Hosting (S3)
✔ EC2-based workloads

---

# 🔮 Future Enhancements

* CloudFront CDN Module
* RDS Database Module
* ALB/NLB Standalone Module
* EKS Kubernetes Module
* CI/CD Terraform Pipeline (GitHub Actions)

---

# 🤝 Contribution Rules

* Keep modules independent
* Avoid hardcoded values
* Follow variable-driven design
* Maintain documentation per module

---

# 📄 License

MIT License — free to use and modify.

---

# 🚀 Final Summary

This repository is a **central Terraform modules registry** that enables:

✔ Fast infrastructure deployment
✔ Production-ready AWS architecture
✔ Modular and reusable infrastructure design
✔ Scalable multi-project support

It is designed to act as a **foundation for all future AWS infrastructure projects**.

```
```
