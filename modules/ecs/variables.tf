variable "region" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "public_subnets" { 
  type = list(string) 
}
# variable "private_subnets" { type = list(string) }

variable "ecs_security_groups" { 
  type = list(string) 
}
variable "alb_security_groups" { 
  type = list(string) 
}

variable "assign_public_ip" { 
  type = bool
  default = true
}

variable "enable_alb" { 
  default = true 
}
variable "enable_autoscaling" { 
  default = false 
}

variable "log_retention_days" { 
  default = 7 
}

variable "services" {
  type = map(object({
    image         = string
    port          = number
    cpu           = number
    memory        = number
    desired_count = number

    environment = map(string)

    path     = list(string)
    priority = number

    health_check_path = optional(string)
  }))
}

variable "autoscaling" {
  type = object({
    min = number
    max = number
    cpu = number
  })

  default = {
    min = 1
    max = 3
    cpu = 70
  }
}

