# 🌐 AWS VPC Terraform Module

![Terraform](https://img.shields.io/badge/Terraform-v1.x-blue)
![AWS](https://img.shields.io/badge/AWS-VPC-orange)
![Module](https://img.shields.io/badge/Module-Reusable-success)

A **scalable and production-ready Terraform module** to provision a fully functional AWS VPC with multi-AZ architecture, networking components, and optional security configurations.

---

## 📌 Module Overview

This module creates a **custom VPC** with:

* 🌍 Multi-AZ public and private subnets
* 🔀 Routing (public & private route tables)
* 🌐 Optional NAT Gateway with Elastic IP
* 🔐 Optional EC2 & Database Security Groups

It is designed to be **fully reusable** and integrates seamlessly with other modules like EC2 and ECS.

---

## ✨ Features

* 🏗️ Multi-AZ architecture (high availability)
* 🌍 Public & private subnet separation
* 🔄 Optional NAT Gateway for outbound internet access
* 🔐 EC2 Security Group with:

  * Default ports: **22 (SSH), 80 (HTTP)**
  * Custom dynamic ingress rules
* 🗄️ Optional DB Security Group
* 📤 Outputs ready for downstream modules

---

## 🛠️ Required Inputs

| Name              | Description                   | Type         | Required |
| ----------------- | ----------------------------- | ------------ | -------- |
| `vpc_name`        | Name of the VPC               | string       | ✅ Yes    |
| `vpc_cidr`        | CIDR block for VPC            | string       | ✅ Yes    |
| `public_subnets`  | List of public subnet CIDRs   | list(string) | ✅ Yes    |
| `private_subnets` | List of private subnet CIDRs  | list(string) | ✅ Yes    |
| `azs`             | Availability Zones (multi-AZ) | list(string) | ✅ Yes    |

---

## ⚙️ Optional Inputs

| Name                 | Description                                                                  | Type         | Default                        |
| -------------------- | ---------------------------------------------------------------------------- | ------------ | ------------------------------ |
| `enable_nat_gateway` | Enable NAT Gateway for private subnets                                       | bool         | `false`                        |
| `create_eip`         | Create Elastic IP for NAT Gateway                                            | bool         | `true`                         |
| `create_ec2_sg`      | Create EC2 Security Group                                                    | bool         | `true`                         |
| `ec2_ingress_rules`  | Custom EC2 ingress rules (`from_port`, `to_port`, `protocol`, `cidr_blocks`) | list(object) | Default includes ports 22 & 80 |
| `db_port`            | Port for Database Security Group                                             | number       | `3306`                         |

---

### 🧠 EC2 Security Group Behavior

* Default rules allow:

  * **SSH (22)**
  * **HTTP (80)**
* If you provide `ec2_ingress_rules`:

  * ⚠️ They **override defaults**
  * You must manually include ports 22/80 if needed

---

## 📤 Outputs

| Name                 | Description                      |
| -------------------- | -------------------------------- |
| `vpc_id`             | VPC ID                           |
| `public_subnet_ids`  | Public subnet IDs                |
| `private_subnet_ids` | Private subnet IDs               |
| `ec2_sg_id`          | EC2 Security Group ID (optional) |
| `db_sg_id`           | DB Security Group ID (optional)  |
| `nat_gateway_id`     | NAT Gateway ID (optional)        |
| `eip_id`             | Elastic IP ID (optional)         |

---

## 🔧 Example Usage

```hcl id="vpc-example"

module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "my-vpc"
  vpc_cidr        = "10.0.0.0/16"

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  azs = ["us-east-1a", "us-east-1b"]

  enable_nat_gateway = true
  create_eip         = true
  create_ec2_sg      = true

  # Custom EC2 ingress rules
  ec2_ingress_rules = [
    { from_port = 22,  to_port = 22,  protocol = "tcp", cidr_blocks = ["YOUR_IP/32"] },
    { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]

  db_port = 3306
}
```

---

## 🧠 Best Practices

* 🔐 Restrict SSH access using your IP (`YOUR_IP/32`)
* 🌍 Use **private subnets** for databases and backend services
* 🔄 Enable NAT Gateway only when required (cost optimization)
* 🏷️ Use consistent naming via `vpc_name`
* ⚖️ Distribute resources across multiple AZs for high availability

---

## 📁 Module Structure

```id="vpc-structure"
modules/
└── vpc/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

## 📄 License

This module is open-source and available under the **MIT License**.

---

## 🤝 Contributing

Contributions are welcome! Feel free to enhance and optimize this module.

---

💡 *Built for scalable, secure, and production-grade AWS networking*
