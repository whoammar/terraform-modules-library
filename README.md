<div align="center">

# 🏗️ Terraform AWS Modular Infrastructure

**A production-grade Terraform modules library for building scalable, secure, and reusable AWS infrastructure.**

[![Terraform](https://img.shields.io/badge/Terraform-≥1.5-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## 📌 Overview

This repository is a **production-grade Terraform modules library** for AWS infrastructure. Each module is independently reusable, variable-driven, and designed with production-ready defaults — so you can build consistent infrastructure across any project or environment.

| Problem | Solution |
|---|---|
| ❌ Repeated Terraform code increases complexity | ✅ Reusable, plug-and-play modules |
| ❌ Hardcoded infrastructure slows down scaling | ✅ Fully variable-driven design |
| ❌ Inconsistency across environments | ✅ Standardized AWS architecture patterns |

---

## 🏛️ Architecture

```
┌──────────────────────────────────────────────────┐
│             Terraform Modules Library             │
└───────────┬──────────┬──────────┬────────────────┘
            │          │          │
         ┌──▼──┐    ┌──▼──┐    ┌──▼──┐    ┌──────┐
         │ VPC │    │ EC2 │    │  S3 │    │ ECS  │
         └──┬──┘    └──┬──┘    └──┬──┘    └──┬───┘
            │          │          │           │
       ┌────▼───┐  ┌───▼───┐  ┌───▼───┐  ┌───▼──────┐
       │Network │  │Compute│  │Storage│  │Container │
       │ Layer  │  │ Layer │  │ Layer │  │  Layer   │
       └────────┘  └───────┘  └───────┘  └──────────┘
```

---

## 📁 Repository Structure

```
terraform-modules-library/
│
├── modules/
│   ├── vpc/                   # Networking foundation
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── ec2/                   # Compute instances
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── s3/                    # Object storage
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── ecs/                   # Container orchestration
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
└── README.md
```

---

## 🧱 Modules

### 🌐 VPC Module

> **Path:** `./modules/vpc` · [Module README](./modules/vpc/README.md)

Provisions a fully functional AWS VPC with multi-AZ architecture as the networking foundation for all other modules.

**Key Features:**
- Multi-AZ public & private subnet separation
- Optional NAT Gateway with Elastic IP
- EC2 Security Group with configurable ingress rules (defaults: port 22, 80)
- Optional DB Security Group

**Required Inputs:**

| Variable | Type | Description |
|---|---|---|
| `vpc_name` | string | Name of the VPC |
| `vpc_cidr` | string | CIDR block for the VPC |
| `public_subnets` | list(string) | Public subnet CIDRs |
| `private_subnets` | list(string) | Private subnet CIDRs |
| `azs` | list(string) | Availability Zones |

**Outputs:** `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `ec2_sg_id`, `db_sg_id`, `nat_gateway_id`, `eip_id`

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "my-vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]

  enable_nat_gateway = true
  create_ec2_sg      = true

  ec2_ingress_rules = [
    { from_port = 22,  to_port = 22,  protocol = "tcp", cidr_blocks = ["YOUR_IP/32"] },
    { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
}
```

---

### 🖥️ EC2 Module

> **Path:** `./modules/ec2` · [Module README](./modules/ec2/README.md)

Reusable EC2 instance provisioning with flexible security group attachment, SSM integration, and user data support.

**Key Features:**
- Dynamic multi-security-group attachment
- Optional AWS SSM access (no SSH required)
- Custom `user_data` startup scripts
- Environment-based tagging

**Required Inputs:**

| Variable | Type | Description |
|---|---|---|
| `ami_id` | string | AMI ID for the EC2 instance |

**Notable Optional Inputs:**

| Variable | Default | Description |
|---|---|---|
| `instance_type` | `t2.micro` | EC2 instance type |
| `instance_name` | `web-server` | Name tag for the instance |
| `enable_ssm` | `false` | Enable SSM Session Manager access |
| `key_name` | `""` | SSH key pair name |
| `user_data` | `""` | Startup script |
| `environment` | `dev` | Environment tag |

**Outputs:** `instance_id`, `public_ip`, `private_ip`

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = "ami-0123456789abcdef0"
  instance_name = "my-app-server"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]
  key_name      = "my-keypair"
  enable_ssm    = true
  environment   = "dev"
  user_data     = file("setup.sh")

  security_group_ids = [module.vpc.ec2_sg_id]
}
```

---

### 🪣 S3 Module

> **Path:** `./modules/s3` · [Module README](./modules/s3/README.md)

Flexible S3 bucket management with all optional features independently toggleable — from static website hosting to lifecycle rules and access logging.

**Key Features:**
- Private by default (matches AWS Console behavior)
- Optional static website hosting
- Versioning, lifecycle rules, and access logging
- Custom or public bucket policy support

**Required Inputs:**

| Variable | Type | Description |
|---|---|---|
| `bucket_name` | string | Name of the S3 bucket |

**Notable Optional Inputs:**

| Variable | Default | Description |
|---|---|---|
| `enable_versioning` | `false` | Enable object versioning |
| `allow_public_access` | `false` | Allow public access to bucket |
| `enable_static_website` | `false` | Enable static website hosting |
| `enable_lifecycle_rule` | `false` | Enable lifecycle rules |
| `lifecycle_expiration_days` | `30` | Days before object expiration |
| `enable_logging` | `false` | Enable access logging |
| `force_destroy` | `false` | Delete bucket even if not empty |
| `environment` | `dev` | Environment tag |

**Outputs:** `bucket_id`, `bucket_arn`, `website_endpoint`

```hcl
# Plain private bucket
module "s3" {
  source      = "./modules/s3"
  bucket_name = "myapp-assets"
  environment = "prod"
}

# Static website with lifecycle + logging
module "s3_website" {
  source = "./modules/s3"

  bucket_name           = "myapp-website"
  environment           = "prod"
  allow_public_access   = true
  enable_static_website = true
  attach_policy         = true
  enable_versioning     = true

  enable_lifecycle_rule     = true
  lifecycle_expiration_days = 60
  lifecycle_transition_days = 30
  lifecycle_storage_class   = "STANDARD_IA"

  enable_logging = true
  log_bucket     = "myapp-logs"
  log_prefix     = "prod/"
}
```

---

### 🚀 ECS Fargate Module

> **Path:** `./modules/ecs` · [Module README](./modules/ecs/README.md)

Production-grade container orchestration on AWS ECS Fargate. Deploys multiple services behind an ALB with path-based routing, CloudWatch logging, and optional CPU-based autoscaling.

**Key Features:**
- Multi-service deployment (e.g. frontend + backend) from a single module call
- ALB with path-based routing rules
- CloudWatch log groups per service
- CPU-based autoscaling (min: 1, max: 3, target: 70%)
- ECS tasks run in private subnets (secure by default)

**Required Inputs:**

| Variable | Type | Description |
|---|---|---|
| `cluster_name` | string | ECS cluster name |
| `vpc_id` | string | VPC ID |
| `public_subnets` | list(string) | Public subnets for ALB |
| `private_subnets` | list(string) | Private subnets for ECS tasks |
| `services` | map(object) | Service definitions (see below) |

**Feature Toggles:**

| Variable | Default | Description |
|---|---|---|
| `enable_alb` | `true` | Enable Application Load Balancer |
| `enable_autoscaling` | `false` | Enable CPU-based autoscaling |
| `assign_public_ip` | `false` | Assign public IP to ECS tasks |

**Service Definition Schema:**

```hcl
services = {
  service_name = {
    image             = string        # Docker image
    port              = number        # Container port
    cpu               = number        # CPU units (e.g. 256)
    memory            = number        # Memory in MB (e.g. 512)
    desired_count     = number        # Number of running tasks
    environment       = map(string)   # Environment variables
    path              = list(string)  # ALB routing paths
    priority          = number        # ALB rule priority (lower = higher priority)
    health_check_path = string        # (optional) Health check path
  }
}
```

**Outputs:** `alb_dns`, `cluster_name`

```hcl
module "ecs" {
  source = "./modules/ecs"

  region       = "us-east-1"
  cluster_name = "prod-cluster"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids

  ecs_security_groups = [module.vpc.ec2_sg_id]
  alb_security_groups = [module.vpc.ec2_sg_id]

  enable_autoscaling = true

  services = {
    api = {
      image         = "mendhak/http-https-echo:40"
      port          = 8888
      cpu           = 256
      memory        = 512
      desired_count = 1
      environment   = { HTTP_PORT = "8888" }
      path          = ["/api/*"]
      priority      = 10
    }

    frontend = {
      image         = "nginx"
      port          = 80
      cpu           = 256
      memory        = 512
      desired_count = 1
      environment   = {}
      path          = ["/*"]
      priority      = 20
    }
  }
}
```

After deployment, access your services via the ALB DNS output:

```
http://<alb_dns>/       → Frontend
http://<alb_dns>/api/*  → Backend API
```

---

## ⚙️ Prerequisites

- **Terraform** `≥ 1.5`
- **AWS CLI** configured with valid credentials
- **IAM permissions** for: `VPC`, `EC2`, `ECS`, `S3`, `ALB`, `IAM Roles`, `CloudWatch`

---

## 🔐 Security Best Practices

| Practice | Detail |
|---|---|
| Private workloads | ECS tasks and databases run in private subnets |
| Controlled ingress | All access via security groups — no open rules |
| No secrets in repo | Use AWS Secrets Manager or SSM Parameter Store |
| SSH alternative | Prefer SSM Session Manager over exposing port 22 |
| Restrict SSH | If SSH is required, scope to `YOUR_IP/32` only |
| Remote state | Use S3 + DynamoDB backend in production |
| Repo hygiene | Never commit `.tfstate` files or sensitive `.tfvars` |

---

## 🧠 Design Principles

- **Reusability first** — every module works standalone or composed with others
- **Environment agnostic** — no environment-specific hardcoding anywhere
- **Secure by default** — private subnets, blocked public access, least-privilege IAM
- **Variable-driven** — all behavior controlled through inputs, no magic values
- **Modular dependency flow** — modules expose clean outputs consumed by other modules

---

## 🗑️ Cleanup

```bash
terraform destroy
```

> ⚠️ Always verify your Terraform state before destroying. This action is irreversible.

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

1. Keep modules **independent** — no cross-module dependencies inside `modules/`
2. Avoid **hardcoded values** — everything through variables
3. Add a `README.md` to every module with inputs, outputs, and an example
4. **Test** your module end-to-end before submitting a PR
5. Follow consistent naming conventions across all resources

---

## 👨‍💻 Author

**Muhammad Ammar**

---

<div align="center">
  <sub>Built with ❤️ using Terraform & AWS</sub>
</div>