# 🪣 AWS S3 Terraform Module

![Terraform](https://img.shields.io/badge/Terraform-v1.x-blue)
![AWS](https://img.shields.io/badge/AWS-S3-orange)
![Module](https://img.shields.io/badge/Module-Reusable-success)

A **professional, reusable Terraform module** to create and manage an AWS S3 bucket with **independent optional features** for real-world production use.

---

## 📌 Module Highlights

This module is designed to behave like the **default AWS Console experience**, while giving you the flexibility to enable advanced features only when needed.

---

## ✨ Features

### 🟢 Default Behavior

* Creates a **private S3 bucket** (same as AWS Console default)

### ⚙️ Optional Capabilities

* 🌍 Public access configuration
* 🌐 Static website hosting
* 🔐 Bucket policy (public or custom)
* 🗂️ Versioning
* ♻️ Lifecycle rules (expiration & storage class transitions)
* 📊 Access logging

---

## 🛠️ Required Inputs

| Name          | Type   | Required |
| ------------- | ------ | -------- |
| `bucket_name` | string | ✅ Yes    |

---

## ⚙️ Optional Inputs

| Name                        | Description                          | Type   | Default         |
| --------------------------- | ------------------------------------ | ------ | --------------- |
| `environment`               | Environment tag (dev/prod)           | string | `"dev"`         |
| `enable_versioning`         | Enable object versioning             | bool   | `false`         |
| `force_destroy`             | Delete bucket even if not empty      | bool   | `false`         |
| `tags`                      | Additional resource tags             | map    | `{}`            |
| `allow_public_access`       | Allow public access to bucket        | bool   | `false`         |
| `block_public_acls`         | Block public ACLs                    | bool   | `true`          |
| `block_public_policy`       | Block public bucket policies         | bool   | `true`          |
| `ignore_public_acls`        | Ignore public ACLs                   | bool   | `true`          |
| `restrict_public_buckets`   | Restrict public buckets              | bool   | `true`          |
| `enable_static_website`     | Enable static website hosting        | bool   | `false`         |
| `index_document`            | Index document for website           | string | `"index.html"`  |
| `error_document`            | Error document for website           | string | `"error.html"`  |
| `attach_policy`             | Attach bucket policy                 | bool   | `false`         |
| `bucket_policy`             | Custom bucket policy JSON            | string | `""`            |
| `enable_lifecycle_rule`     | Enable lifecycle rules               | bool   | `false`         |
| `lifecycle_expiration_days` | Days before object expiration        | number | `30`            |
| `lifecycle_transition_days` | Days before storage class transition | number | `0`             |
| `lifecycle_storage_class`   | Storage class for transition         | string | `"STANDARD_IA"` |
| `enable_logging`            | Enable access logging                | bool   | `false`         |
| `log_bucket`                | Target bucket for logs               | string | `""`            |
| `log_prefix`                | Log file prefix                      | string | `""`            |

---

## 📦 Example Usage

### 🔹 Example 1: Plain Private Bucket (Default)

```hcl id="ex1s3"
module "s3_bucket" {
  source      = "./modules/s3"
  bucket_name = "myapp-dev"
  environment = "dev"
}
```

---

### 🔹 Example 2: Static Website Hosting + Advanced Features

```hcl id="ex2s3"
module "s3_bucket_website" {
  source = "./modules/s3"

  bucket_name           = "myapp-prod"
  environment           = "prod"
  allow_public_access   = true
  enable_static_website = true
  attach_policy         = true

  index_document = "index.html"
  error_document = "error.html"

  enable_lifecycle_rule     = true
  lifecycle_expiration_days = 60
  lifecycle_transition_days = 30
  lifecycle_storage_class   = "STANDARD_IA"

  enable_logging = true
  log_bucket     = "myapp-logs"
  log_prefix     = "prod/"

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::myapp-prod/*"
    }
  ]
}
EOF
}
```

---

## 🧠 Best Practices

* 🔒 Keep buckets **private by default**
* 🌍 Enable public access **only for static websites**
* 🗂️ Use **versioning** for critical data
* ♻️ Apply lifecycle rules to reduce storage costs
* 📊 Enable logging for audit and monitoring

---

## 📁 Module Structure

```id="s3struct"
modules/
└── s3/
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

Contributions are welcome! Feel free to fork this module and submit improvements.

---

💡 *Designed for scalable, secure, and production-ready S3 deployments*
