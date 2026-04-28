# 🚀 ECS Fargate Terraform Module (Production Ready)

A fully reusable and production-grade Terraform module for deploying **containerized applications on AWS ECS Fargate** with support for:

* Multi-service architecture (frontend, backend, APIs)
* Application Load Balancer (ALB)
* Path-based routing
* CloudWatch logging
* Autoscaling (CPU-based)
* Secure networking (private subnets)

---

# 📌 Architecture Overview

This module provisions:

* ECS Cluster
* ECS Services (multiple)
* Task Definitions
* IAM Roles (Execution + Task)
* CloudWatch Log Groups
* Application Load Balancer (optional)
* Target Groups
* Listener + Path-based routing rules
* Autoscaling policies (optional)

---

# ✨ Features

## ✅ Multi-Service Deployment

Deploy multiple services (e.g., frontend + backend) using a single module.

## ✅ ALB with Path-Based Routing

Route traffic based on URL paths:

* `/api/*` → backend
* `/*` → frontend

## ✅ CloudWatch Logging

Each service gets its own log group for easy debugging.

## ✅ Autoscaling Support

Automatically scale services based on CPU utilization.

## ✅ Secure by Default

* Runs ECS tasks in **private subnets**
* ALB handles public traffic

## ✅ Fully Reusable

Parameter-driven design for use across multiple environments/projects.

---

# 📂 Module Structure

```
modules/ecs/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

---

# ⚙️ Requirements

* Terraform >= 1.0
* AWS Provider >= 4.0
* Existing VPC module (like yours)

---

# 🔧 Inputs

## Core Variables

| Name                | Type         | Description                     |
| ------------------- | ------------ | ------------------------------- |
| region              | string       | AWS region                      |
| cluster_name        | string       | ECS cluster name                |
| vpc_id              | string       | VPC ID                          |
| public_subnets      | list(string) | Public subnets (for ALB)        |
| private_subnets     | list(string) | Private subnets (for ECS tasks) |
| ecs_security_groups | list(string) | Security groups for ECS         |
| alb_security_groups | list(string) | Security groups for ALB         |

---

## Feature Toggles

| Name               | Type | Default | Description             |
| ------------------ | ---- | ------- | ----------------------- |
| enable_alb         | bool | true    | Enable ALB              |
| enable_autoscaling | bool | false   | Enable autoscaling      |
| assign_public_ip   | bool | false   | Assign public IP to ECS |

---

## Services (Most Important)

```hcl
services = {
  service_name = {
    image         = string
    port          = number
    cpu           = number
    memory        = number
    desired_count = number

    environment = map(string)

    path     = list(string)
    priority = number

    health_check_path = optional(string)
  }
}
```

---

# 🚀 Example Usage

```hcl

module "ecs" {
  source = "../modules/ecs"

  region       = "ap-south-1"
  cluster_name = "my-ecs"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids

  ecs_security_groups = [module.vpc.ec2_sg_id]
  alb_security_groups = [module.vpc.ec2_sg_id]

  services = {
    api = {
      image         = "mendhak/http-https-echo:40"
      port          = 8888
      cpu           = 256
      memory        = 512
      desired_count = 1

      environment = {
        HTTP_PORT = "8888"
      }

      path     = ["/api/*"]
      priority = 10
    }

    frontend = {
      image         = "nginx"
      port          = 80
      cpu           = 256
      memory        = 512
      desired_count = 1

      environment = {}

      path     = ["/*"]
      priority = 20
    }
  }
}
```

---

# 🌐 Accessing Services

After deployment:

* ALB DNS will be available via output:

```hcl
output "alb_dns"
```

### Example:

```
http://<alb-dns>/       → Frontend
http://<alb-dns>/api   → Backend
```

---

# 📈 Autoscaling

Enable autoscaling:

```hcl
enable_autoscaling = true
```

Default configuration:

* Min: 1
* Max: 3
* CPU target: 70%

---

# 🧪 Debugging (Recommended by Instructor)

Use this image for debugging routing issues:

```
mendhak/http-https-echo:40
```

It shows:

* Request path
* Headers
* Hostname (task IP)

---

# 🔐 Networking Best Practices

* ECS tasks run in **private subnets**
* ALB is public-facing
* NAT Gateway required for internet access from private subnets

---

# ⚠️ Common Issues

## ❌ Frontend Not Loading

* Check ALB path rules
* Ensure:

  * `/api/*` → backend (priority 10)
  * `/*` → frontend (priority 20)

## ❌ Empty Response

* Likely routing issue
* Use echo container for debugging

---

# 📤 Outputs

| Name         | Description      |
| ------------ | ---------------- |
| alb_dns      | ALB DNS name     |
| cluster_name | ECS cluster name |

---

# 📌 Notes

* No Auto Scaling Group needed (Fargate handles infra)
* ALB is required for multi-service routing
* Designed for production use

---

# 🏁 Conclusion

This module enables you to deploy **scalable, production-ready containerized applications** on AWS ECS Fargate with minimal configuration and maximum flexibility.

---

