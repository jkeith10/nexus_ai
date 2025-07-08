# Nexus AI Agent Framework - Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying the Nexus AI Agent Framework across different environments, from local development to production-scale deployments.

## 🚀 Quick Start

### Prerequisites

- **Docker & Docker Compose**: Version 20.10+ and 2.0+
- **Git**: For cloning the repository
- **Make**: For simplified deployment commands (optional)
- **8GB RAM minimum**: 16GB+ recommended for production
- **4 CPU cores minimum**: 8+ cores recommended for production

### Local Development Deployment

```bash
# Clone the repository
git clone https://github.com/your-org/nexus-ai.git
cd nexus-ai

# Copy environment configuration
cp .env.example .env

# Edit environment variables
nano .env

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### Environment Configuration

Create a `.env` file with the following variables:

```bash
# Database Configuration
POSTGRES_DB=nexus_ai
POSTGRES_USER=nexus_user
POSTGRES_PASSWORD=secure_password_here
POSTGRES_HOST=nexus-postgres
POSTGRES_PORT=5432

# Redis Configuration
REDIS_HOST=nexus-redis
REDIS_PORT=6379
REDIS_PASSWORD=redis_password_here

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here
JWT_ALGORITHM=HS256
JWT_EXPIRY=3600

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
API_RELOAD=true

# Core Service Configuration
CORE_HOST=0.0.0.0
CORE_PORT=8080
QUANTUM_ENGINE_ENABLED=true
COGNITIVE_NETWORK_NODES=4

# AI Module Configuration
AI_HOST=0.0.0.0
AI_PORT=8081
RAY_ADDRESS=nexus-ray:6379
CUDA_VISIBLE_DEVICES=0
GPU_MEMORY_LIMIT=8GB

# UI Configuration
UI_HOST=0.0.0.0
UI_PORT=3000
REACT_APP_API_URL=http://localhost:8000

# Monitoring Configuration
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
ELASTICSEARCH_PORT=9200
KIBANA_PORT=5601

# Security Configuration
ENCRYPTION_KEY=your_encryption_key_here
RATE_LIMIT_PER_MINUTE=100
MAX_SESSION_DURATION=3600

# External Services
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

## 🏗️ Production Deployment

### Docker Swarm Deployment

```bash
# Initialize Docker Swarm
docker swarm init

# Deploy the stack
docker stack deploy -c docker-compose.prod.yml nexus-ai

# Check service status
docker service ls

# Scale services
docker service scale nexus-ai_api=3
docker service scale nexus-ai_ai_module=5
```

### Kubernetes Deployment

```bash
# Create namespace
kubectl create namespace nexus-ai

# Apply configurations
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/storage.yaml
kubectl apply -f k8s/services.yaml
kubectl apply -f k8s/deployments.yaml
kubectl apply -f k8s/ingress.yaml

# Check deployment status
kubectl get pods -n nexus-ai
kubectl get services -n nexus-ai
```

### Kubernetes Configuration Files

#### `k8s/namespace.yaml`
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-ai
  labels:
    name: nexus-ai
```

#### `k8s/configmap.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nexus-ai-config
  namespace: nexus-ai
data:
  POSTGRES_DB: "nexus_ai"
  POSTGRES_HOST: "nexus-postgres"
  REDIS_HOST: "nexus-redis"
  API_HOST: "0.0.0.0"
  API_PORT: "8000"
  CORE_HOST: "0.0.0.0"
  CORE_PORT: "8080"
  AI_HOST: "0.0.0.0"
  AI_PORT: "8081"
  RAY_ADDRESS: "nexus-ray:6379"
```

#### `k8s/secrets.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: nexus-ai-secrets
  namespace: nexus-ai
type: Opaque
data:
  POSTGRES_PASSWORD: <base64-encoded-password>
  JWT_SECRET: <base64-encoded-jwt-secret>
  ENCRYPTION_KEY: <base64-encoded-encryption-key>
  REDIS_PASSWORD: <base64-encoded-redis-password>
```

#### `k8s/deployments.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-core
  namespace: nexus-ai
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nexus-core
  template:
    metadata:
      labels:
        app: nexus-core
    spec:
      containers:
      - name: nexus-core
        image: nexus-ai/core:latest
        ports:
        - containerPort: 8080
        envFrom:
        - configMapRef:
            name: nexus-ai-config
        - secretRef:
            name: nexus-ai-secrets
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-ai-module
  namespace: nexus-ai
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nexus-ai-module
  template:
    metadata:
      labels:
        app: nexus-ai-module
    spec:
      containers:
      - name: nexus-ai-module
        image: nexus-ai/ai-module:latest
        ports:
        - containerPort: 8081
        envFrom:
        - configMapRef:
            name: nexus-ai-config
        - secretRef:
            name: nexus-ai-secrets
        resources:
          requests:
            memory: "2Gi"
            cpu: "500m"
            nvidia.com/gpu: 1
          limits:
            memory: "4Gi"
            cpu: "1000m"
            nvidia.com/gpu: 1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-api
  namespace: nexus-ai
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nexus-api
  template:
    metadata:
      labels:
        app: nexus-api
    spec:
      containers:
      - name: nexus-api
        image: nexus-ai/api:latest
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: nexus-ai-config
        - secretRef:
            name: nexus-ai-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

## 🔧 Infrastructure as Code

### Terraform Configuration

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "nexus_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nexus-ai-vpc"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "nexus_cluster" {
  name     = "nexus-ai-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.24"

  vpc_config {
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

# RDS Database
resource "aws_db_instance" "nexus_postgres" {
  identifier           = "nexus-ai-postgres"
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = "db.r5.large"
  allocated_storage    = 100
  storage_type         = "gp3"
  storage_encrypted    = true
  db_name              = "nexus_ai"
  username             = "nexus_user"
  password             = var.db_password
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.nexus.name
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "nexus_redis" {
  cluster_id           = "nexus-ai-redis"
  engine               = "redis"
  node_type            = "cache.r5.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.nexus.name
}
```

### Ansible Playbook

```yaml
# playbook.yml
---
- name: Deploy Nexus AI Framework
  hosts: nexus_servers
  become: yes
  vars:
    nexus_version: "0.1.0"
    docker_compose_version: "2.20.0"
    
  tasks:
    - name: Update system packages
      apt:
        update_cache: yes
        upgrade: yes
      when: ansible_os_family == "Debian"

    - name: Install Docker
      apt:
        name:
          - docker.io
          - docker-compose-plugin
        state: present

    - name: Install Docker Compose
      get_url:
        url: "https://github.com/docker/compose/releases/download/v{{ docker_compose_version }}/docker-compose-linux-x86_64"
        dest: /usr/local/bin/docker-compose
        mode: '0755'

    - name: Create nexus user
      user:
        name: nexus
        system: yes
        shell: /bin/bash
        home: /opt/nexus

    - name: Create application directory
      file:
        path: /opt/nexus
        state: directory
        owner: nexus
        group: nexus
        mode: '0755'

    - name: Copy application files
      copy:
        src: "{{ item }}"
        dest: /opt/nexus/
        owner: nexus
        group: nexus
      with_items:
        - docker-compose.yml
        - .env
        - core/
        - ai/
        - api/
        - ui/

    - name: Start Nexus AI services
      docker_compose:
        project_src: /opt/nexus
        state: present
      become_user: nexus

    - name: Wait for services to be ready
      wait_for:
        host: "{{ item }}"
        port: "{{ item.port }}"
        delay: 10
        timeout: 300
      with_items:
        - { host: "localhost", port: 8000 }
        - { host: "localhost", port: 8080 }
        - { host: "localhost", port: 8081 }
```

## 🔒 Security Configuration

### SSL/TLS Setup

```bash
# Generate SSL certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nexus-ai.key -out nexus-ai.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=nexus-ai.com"

# Configure Nginx with SSL
server {
    listen 443 ssl http2;
    server_name nexus-ai.com;
    
    ssl_certificate /etc/ssl/certs/nexus-ai.crt;
    ssl_certificate_key /etc/ssl/private/nexus-ai.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass http://nexus-ui:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /api/ {
        proxy_pass http://nexus-api:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Firewall Configuration

```bash
# UFW Firewall Rules
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow ssh

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow internal Docker communication
ufw allow from 172.16.0.0/12
ufw allow from 192.168.0.0/16

# Enable firewall
ufw enable
```

## 📊 Monitoring Setup

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "nexus_rules.yml"

scrape_configs:
  - job_name: 'nexus-core'
    static_configs:
      - targets: ['nexus-core:8080']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'nexus-ai'
    static_configs:
      - targets: ['nexus-ai:8081']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'nexus-api'
    static_configs:
      - targets: ['nexus-api:8000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'postgres'
    static_configs:
      - targets: ['nexus-postgres:5432']
    metrics_path: '/metrics'

  - job_name: 'redis'
    static_configs:
      - targets: ['nexus-redis:6379']
    metrics_path: '/metrics'
```

### Grafana Dashboards

```json
{
  "dashboard": {
    "title": "Nexus AI Framework Overview",
    "panels": [
      {
        "title": "Decision Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(decision_duration_seconds_bucket[5m]))",
            "legendFormat": "P95 Latency"
          }
        ]
      },
      {
        "title": "System Health",
        "type": "stat",
        "targets": [
          {
            "expr": "nexus_system_health_score",
            "legendFormat": "Health Score"
          }
        ]
      },
      {
        "title": "Resource Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(container_cpu_usage_seconds_total{container=~\"nexus.*\"}[5m])",
            "legendFormat": "CPU Usage"
          },
          {
            "expr": "rate(container_memory_usage_bytes{container=~\"nexus.*\"}[5m])",
            "legendFormat": "Memory Usage"
          }
        ]
      }
    ]
  }
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Nexus AI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r ai/requirements.txt
        pip install -r api/requirements.txt
    
    - name: Run tests
      run: |
        pytest ai/tests/
        pytest api/tests/

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Core
      uses: docker/build-push-action@v4
      with:
        context: ./core
        push: true
        tags: nexus-ai/core:latest
    
    - name: Build and push AI Module
      uses: docker/build-push-action@v4
      with:
        context: ./ai
        push: true
        tags: nexus-ai/ai-module:latest
    
    - name: Build and push API
      uses: docker/build-push-action@v4
      with:
        context: ./api
        push: true
        tags: nexus-ai/api:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: |
        echo ${{ secrets.KUBECONFIG }} | base64 -d > kubeconfig
        export KUBECONFIG=kubeconfig
        kubectl apply -f k8s/
        kubectl rollout restart deployment/nexus-core -n nexus-ai
        kubectl rollout restart deployment/nexus-ai-module -n nexus-ai
        kubectl rollout restart deployment/nexus-api -n nexus-ai
```

## 🚨 Troubleshooting

### Common Issues

#### Service Won't Start

```bash
# Check service logs
docker-compose logs nexus-core
docker-compose logs nexus-ai
docker-compose logs nexus-api

# Check resource usage
docker stats

# Restart specific service
docker-compose restart nexus-core
```

#### Database Connection Issues

```bash
# Check database status
docker-compose exec nexus-postgres psql -U nexus_user -d nexus_ai -c "SELECT version();"

# Check connection from API
docker-compose exec nexus-api python -c "
import psycopg2
conn = psycopg2.connect(
    host='nexus-postgres',
    database='nexus_ai',
    user='nexus_user',
    password='your_password'
)
print('Connection successful')
"
```

#### Memory Issues

```bash
# Check memory usage
free -h
docker system df

# Clean up unused resources
docker system prune -a
docker volume prune
```

#### Performance Issues

```bash
# Check CPU and memory usage
htop
docker stats

# Check network connectivity
docker-compose exec nexus-core ping nexus-ai
docker-compose exec nexus-core ping nexus-api

# Check service health endpoints
curl http://localhost:8080/health
curl http://localhost:8081/health
curl http://localhost:8000/health
```

### Log Analysis

```bash
# View real-time logs
docker-compose logs -f --tail=100

# Search for errors
docker-compose logs | grep -i error

# Export logs for analysis
docker-compose logs > nexus-logs.txt

# Analyze with ELK stack
# Logs are automatically sent to Elasticsearch
# Access Kibana at http://localhost:5601
```

## 📈 Scaling Guidelines

### Horizontal Scaling

```bash
# Scale API services
docker-compose up -d --scale nexus-api=5

# Scale AI modules
docker-compose up -d --scale nexus-ai=10

# Scale with Kubernetes
kubectl scale deployment nexus-api --replicas=10 -n nexus-ai
kubectl scale deployment nexus-ai-module --replicas=20 -n nexus-ai
```

### Resource Optimization

```yaml
# Optimized resource limits
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
  
  # For AI modules with GPU
  ai_module:
    requests:
      memory: "2Gi"
      cpu: "500m"
      nvidia.com/gpu: 1
    limits:
      memory: "4Gi"
      cpu: "1000m"
      nvidia.com/gpu: 1
```

## 🔗 Additional Resources

- [Architecture Documentation](./architecture.md)
- [API Reference](./api-reference.md)
- [Security Guide](./security.md)
- [Performance Tuning](./performance.md)
- [Monitoring Guide](./monitoring.md) 