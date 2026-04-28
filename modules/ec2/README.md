# 🚀 AWS EC2 Terraform Module

![Terraform](https://img.shields.io/badge/Terraform-v1.x-blue)
![AWS](https://img.shields.io/badge/AWS-EC2-orange)
![License](https://img.shields.io/badge/License-MIT-green)

A reusable and production-ready Terraform module to provision an **AWS EC2 instance** with flexible configuration options.

This module supports:

* 🔐 Multiple Security Groups (dynamic input)
* ⚙️ Optional SSM integration
* 📜 Custom `user_data` scripts
* 🏷️ Environment-based naming conventions

---

## 📌 Module Overview

This module simplifies EC2 provisioning by providing sensible defaults while allowing customization for real-world deployments.

---

## 🛠️ Required Inputs

| Name     | Description    | Type   | Required |
| -------- | -------------- | ------ | -------- |
| `ami_id` | AMI ID for EC2 | string | ✅ Yes    |

---

## ⚙️ Optional Inputs

| Name                 | Description                       | Type         | Default        |
| -------------------- | --------------------------------- | ------------ | -------------- |
| `instance_name`      | Name of the EC2 instance          | string       | `"web-server"` |
| `instance_type`      | EC2 instance type                 | string       | `"t2.micro"`   |
| `subnet_id`          | Subnet ID for EC2 deployment      | string       | `null`         |
| `security_group_ids` | List of Security Group IDs        | list(string) | `[]`           |
| `key_name`           | SSH key pair name                 | string       | `""`           |
| `user_data`          | Startup script for instance       | string       | `""`           |
| `enable_ssm`         | Enable AWS SSM access             | bool         | `false`        |
| `environment`        | Environment tag (e.g., dev, prod) | string       | `"dev"`        |

---

## 📤 Outputs

| Name          | Description            |
| ------------- | ---------------------- |
| `instance_id` | ID of the EC2 instance |
| `public_ip`   | Public IP address      |
| `private_ip`  | Private IP address     |

---

## 🔧 Example Usage

```hcl
module "ec2" {
  source = "./modules/ec2"

  ami_id        = "ami-0123456789abcdef0"
  instance_name = "my-app-server"
  key_name      = "my-keypair"

  enable_ssm  = true
  environment = "dev"

  user_data = file("setup.sh")

  security_group_ids = [
    module.vpc.ec2_sg_id,
    module.vpc.db_sg_id
  ]
}
```

---

## 🧩 Best Practices

* Use **SSM instead of SSH** where possible for better security
* Keep AMIs updated and region-specific
* Avoid hardcoding values — use variables or data sources
* Tag resources properly using the `environment` variable

---

## 📁 Module Structure

```
modules/
└── ec2/
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

Feel free to fork, improve, and submit pull requests to enhance this module.

---

💡 *Built for scalable and production-ready Terraform workflows*
