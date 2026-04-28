<div align="center">

# 🏗️ Terraform AWS Modular Infrastructure

**A production-grade Terraform modules library for scalable, reusable AWS infrastructure.**

[![Terraform](https://img.shields.io/badge/Terraform-≥1.5-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## 📌 Overview

This repository is a **production-grade Terraform modules library** designed to build scalable and reusable AWS infrastructure. It provides a modular architecture where each infrastructure component is independent, reusable, and production-ready.

| Problem | Solution |
|---|---|
| ❌ Repeated Terraform code increases complexity | ✅ Reusable infrastructure modules |
| ❌ Hardcoded infrastructure slows scaling | ✅ Standardized AWS architecture patterns |
| ❌ Managing multiple projects becomes inconsistent | ✅ Clean separation of concerns |

---

## 🏛️ Architecture

```
┌──────────────────────────────────────┐
│        Terraform Modules Library     │
└────────────────┬─────────────────────┘
                 │
     ┌───────────┼───────────┐
     │           │           │
  ┌──▼──┐    ┌───▼──┐    ┌───▼──┐
  │ VPC │    │  EC2 │    │  S3  │
  └──┬──┘    └───┬──┘    └───┬──┘
     │           │           │
  ┌──▼────┐  ┌───▼───┐  ┌───▼────┐
  │Network│  │Compute│  │Storage │
  │ Layer │  │ Layer │  │  Layer │
  └───────┘  └───────┘  └────────┘
```

---

## 📁 Repository Structure

```
terraform-modules-library/
│
├── modules/
│   ├── vpc/              # Networking foundation
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── ec2/              # Compute instances
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── s3/               # Object storage
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── ecs/              # Container orchestration
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

<details>
<summary><strong>🌐 VPC Module</strong> — Complete networking foundation</summary>

<br>

Creates a full networking stack with all essential components:

- ✅ Multi-AZ VPC
- ✅ Public & Private Subnets
- ✅ NAT Gateway *(optional)*
- ✅ Route Tables
- ✅ Security Groups (EC2 & DB)

</details>

<details>
<summary><strong>🖥️ EC2 Module</strong> — Reusable compute provisioning</summary>

<br>

Flexible EC2 instance module supporting:

- ✅ AMI-based instances
- ✅ Security group support
- ✅ User data scripts
- ✅ SSM optional support
- ✅ Environment tagging

</details>

<details>
<summary><strong>🪣 S3 Module</strong> — Flexible object storage</summary>

<br>

Full-featured S3 bucket management:

- ✅ Private by default
- ✅ Static website hosting
- ✅ Versioning support
- ✅ Lifecycle rules
- ✅ Logging support
- ✅ Public access control options

</details>

<details>
<summary><strong>🚀 ECS Fargate Module</strong> — Production container orchestration</summary>

<br>

Enterprise-grade container deployment:

- ✅ Multi-service deployment (frontend/backend)
- ✅ ALB integration
- ✅ Path-based routing
- ✅ CloudWatch logging
- ✅ Autoscaling support
- ✅ Fully serverless containers (Fargate)

</details>

---

## ⚙️ Prerequisites

Before getting started, ensure you have the following:

- **Terraform** `≥ 1.5`
- **AWS CLI** configured with appropriate credentials
- **IAM Permissions** for: `VPC`, `EC2`, `ECS`, `S3`, `ALB`, `IAM Roles`, `CloudWatch`

---

## 🚀 Quick Start

### 1️⃣ VPC Module

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

### 2️⃣ ECS Fargate Application

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
      path          = ["/api/*"]
      priority      = 10
    }

    frontend = {
      image         = "nginx"
      port          = 80
      cpu           = 256
      memory        = 512
      desired_count = 1
      path          = ["/*"]
      priority      = 20
    }
  }
}
```

### 3️⃣ EC2 Instance

```hcl
module "ec2" {
  source = "git@github.com:whoammar/terraform-modules-library.git//modules/ec2"

  ami_id             = "ami-0c55b159cbfafe1f0"
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.vpc.ec2_sg_id]
  instance_name      = "web-server"
}
```

### 4️⃣ S3 Bucket

```hcl
module "s3" {
  source = "git@github.com:whoammar/terraform-modules-library.git//modules/s3"

  bucket_name = "my-terraform-bucket"
  versioning  = true
  environment = "production"
}
```

---

## 🔐 Security Best Practices

| Practice | Implementation |
|---|---|
| Private workloads | ECS services run in private subnets |
| Controlled access | Security groups on all resources |
| Public traffic handling | ALB manages ingress, not services directly |
| No secret exposure | Use AWS Secrets Manager or SSM Parameter Store |
| State security | Use remote backend (S3 + DynamoDB) |
| Repo hygiene | Never commit `.tfstate` or sensitive `.tfvars` |

---

## 🧠 Design Principles

```
  Reusability First        →  Modules work across any project
  Environment Agnostic     →  No environment-specific hardcoding
  Production-Ready         →  Secure defaults out of the box
  Modular Dependencies     →  Clean, predictable dependency flow
  Secure by Default        →  Least-privilege, private-first architecture
```

---

## 📦 Real-World Projects

| Project | Description |
|---|---|
| 🔒 VPN Tunnel Infrastructure | OpenVPN tunnel on EC2 |
| 🚀 ECS Fargate Multi-tier App | Full frontend + API deployment |
| 🔍 Mendhak Debug Echo Service | HTTP echo service for debugging |
| 🌐 Static Website Hosting | S3-based static site |
| 🖥️ EC2-based Workloads | General-purpose compute |

---

## 🗑️ Cleanup

To tear down any infrastructure deployed with these modules:

```bash
terraform destroy
```

> ⚠️ **Warning:** This is irreversible. Ensure you have backups of any important state or data before running.

---

## 🔮 Roadmap

- [ ] CloudFront CDN Module
- [ ] RDS Database Module
- [ ] Standalone ALB / NLB Module
- [ ] EKS Kubernetes Module
- [ ] CI/CD Pipeline via GitHub Actions
- [ ] CloudWatch Dashboards Module

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Keep modules **independent** and self-contained
2. Avoid **hardcoded values** — use variables
3. Follow **variable-driven design** patterns
4. **Document** every module with a `README.md`
5. **Test** your module before submitting a PR

---

## 👨‍💻 Author

**Muhammad Ammar**

---

<div align="center">
  <sub>Built with ❤️ using Terraform & AWS</sub>
</div>