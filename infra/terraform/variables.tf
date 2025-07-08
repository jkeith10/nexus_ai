# Nexus AI Agent Framework - Terraform Variables
# Input variables for infrastructure configuration

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "nexus-ai-cluster"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "nexus-ai.example.com"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r5.large"
  
  validation {
    condition     = contains(["db.t3.micro", "db.t3.small", "db.t3.medium", "db.r5.large", "db.r5.xlarge", "db.r5.2xlarge"], var.db_instance_class)
    error_message = "Invalid RDS instance class."
  }
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 100
  
  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 16384
    error_message = "Allocated storage must be between 20 and 16384 GB."
  }
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.r5.large"
  
  validation {
    condition     = contains(["cache.t3.micro", "cache.t3.small", "cache.r5.large", "cache.r5.xlarge", "cache.r5.2xlarge"], var.redis_node_type)
    error_message = "Invalid Redis node type."
  }
}

variable "eks_node_groups" {
  description = "EKS node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = number
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 1
      max_size       = 10
      disk_size      = 20
    }
    gpu = {
      instance_types = ["g4dn.xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 1
      max_size       = 5
      disk_size      = 100
    }
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Invalid VPC CIDR block."
  }
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  
  validation {
    condition = alltrue([
      for subnet in var.private_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "Invalid private subnet CIDR blocks."
  }
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  validation {
    condition = alltrue([
      for subnet in var.public_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "Invalid public subnet CIDR blocks."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.28"
  
  validation {
    condition     = can(regex("^1\\.(2[0-8]|1[0-9]|[0-9])$", var.cluster_version))
    error_message = "Invalid EKS cluster version. Must be 1.0-1.28."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks for public access to EKS cluster endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "eks_addons" {
  description = "EKS add-ons configuration"
  type = map(object({
    most_recent = bool
    version     = optional(string)
  }))
  default = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.rds_backup_retention_period >= 0 && var.rds_backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "rds_backup_window" {
  description = "RDS backup window"
  type        = string
  default     = "03:00-04:00"
  
  validation {
    condition     = can(regex("^([0-1]?[0-9]|2[0-3]):[0-5][0-9]-([0-1]?[0-9]|2[0-3]):[0-5][0-9]$", var.rds_backup_window))
    error_message = "Invalid backup window format. Use HH:MM-HH:MM."
  }
}

variable "rds_maintenance_window" {
  description = "RDS maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
  
  validation {
    condition     = can(regex("^(sun|mon|tue|wed|thu|fri|sat):([0-1]?[0-9]|2[0-3]):[0-5][0-9]-(sun|mon|tue|wed|thu|fri|sat):([0-1]?[0-9]|2[0-3]):[0-5][0-9]$", var.rds_maintenance_window))
    error_message = "Invalid maintenance window format. Use day:HH:MM-day:HH:MM."
  }
}

variable "rds_monitoring_interval" {
  description = "RDS monitoring interval in seconds"
  type        = number
  default     = 60
  
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.rds_monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes for Redis"
  type        = number
  default     = 1
  
  validation {
    condition     = var.redis_num_cache_nodes >= 1 && var.redis_num_cache_nodes <= 20
    error_message = "Number of cache nodes must be between 1 and 20."
  }
}

variable "redis_parameter_group_name" {
  description = "Redis parameter group name"
  type        = string
  default     = "default.redis6.x"
}

variable "s3_bucket_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_bucket_encryption" {
  description = "Enable S3 bucket encryption"
  type        = bool
  default     = true
}

variable "s3_bucket_public_access_block" {
  description = "Block public access to S3 bucket"
  type        = bool
  default     = true
}

variable "alb_internal" {
  description = "Make ALB internal (not internet-facing)"
  type        = bool
  default     = false
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "alb_health_check_path" {
  description = "Health check path for ALB target groups"
  type        = string
  default     = "/health"
}

variable "alb_health_check_interval" {
  description = "Health check interval for ALB target groups"
  type        = number
  default     = 30
  
  validation {
    condition     = var.alb_health_check_interval >= 5 && var.alb_health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "alb_health_check_timeout" {
  description = "Health check timeout for ALB target groups"
  type        = number
  default     = 5
  
  validation {
    condition     = var.alb_health_check_timeout >= 2 && var.alb_health_check_timeout <= 60
    error_message = "Health check timeout must be between 2 and 60 seconds."
  }
}

variable "alb_health_check_healthy_threshold" {
  description = "Healthy threshold for ALB health checks"
  type        = number
  default     = 2
  
  validation {
    condition     = var.alb_health_check_healthy_threshold >= 2 && var.alb_health_check_healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "alb_health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for ALB health checks"
  type        = number
  default     = 2
  
  validation {
    condition     = var.alb_health_check_unhealthy_threshold >= 2 && var.alb_health_check_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
}

variable "ssl_certificate_validation_method" {
  description = "SSL certificate validation method"
  type        = string
  default     = "DNS"
  
  validation {
    condition     = contains(["DNS", "EMAIL"], var.ssl_certificate_validation_method)
    error_message = "SSL certificate validation method must be DNS or EMAIL."
  }
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_retention_days)
    error_message = "Invalid log retention period. Must be one of the allowed values."
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "nexus-ai"
    ManagedBy   = "terraform"
    Environment = "prod"
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging stack (ELK)"
  type        = bool
  default     = true
}

variable "enable_alerting" {
  description = "Enable alerting (SNS, CloudWatch Alarms)"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "alerts@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Invalid email address format."
  }
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Backup schedule (cron expression)"
  type        = string
  default     = "0 2 * * *"
  
  validation {
    condition     = can(regex("^[0-9*/, -]+$", var.backup_schedule))
    error_message = "Invalid cron expression format."
  }
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for EKS node groups"
  type        = bool
  default     = true
}

variable "auto_scaling_min_size" {
  description = "Minimum size for auto scaling groups"
  type        = number
  default     = 1
  
  validation {
    condition     = var.auto_scaling_min_size >= 0
    error_message = "Auto scaling min size must be non-negative."
  }
}

variable "auto_scaling_max_size" {
  description = "Maximum size for auto scaling groups"
  type        = number
  default     = 10
  
  validation {
    condition     = var.auto_scaling_max_size >= var.auto_scaling_min_size
    error_message = "Auto scaling max size must be greater than or equal to min size."
  }
}

variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "enable_security_hardening" {
  description = "Enable security hardening features"
  type        = bool
  default     = true
}

variable "enable_compliance" {
  description = "Enable compliance features (HIPAA, SOC2, etc.)"
  type        = bool
  default     = false
} 