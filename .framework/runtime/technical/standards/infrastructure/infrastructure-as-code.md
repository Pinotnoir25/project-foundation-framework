# Infrastructure as Code

## Overview

This document outlines the Infrastructure as Code (IaC) approach for the Nexus MCP project, covering cloud resource provisioning, configuration management, and disaster recovery procedures using Terraform, Docker Compose, and Kubernetes manifests.

## Terraform for Cloud Resources

### Project Structure

```
infrastructure/
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   ├── staging/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   └── prod/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── terraform.tfvars
│   │       └── backend.tf
│   ├── modules/
│   │   ├── eks/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── mongodb/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── bastion/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── global/
│       ├── s3/
│       └── iam/
```

### VPC Module

```hcl
# infrastructure/terraform/modules/vpc/main.tf
resource "aws_vpc" "nexus" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-vpc"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.nexus.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                           = "${var.environment}-nexus-public-${var.availability_zones[count.index]}"
      "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
      "kubernetes.io/role/elb"                       = "1"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.nexus.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 100)
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name                                           = "${var.environment}-nexus-private-${var.availability_zones[count.index]}"
      "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
      "kubernetes.io/role/internal-elb"              = "1"
    }
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.nexus.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 200)
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-db-${var.availability_zones[count.index]}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "nexus" {
  vpc_id = aws_vpc.nexus.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-igw"
    }
  )
}

# NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-nat-eip-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "nexus" {
  count         = var.enable_nat_gateway ? length(var.availability_zones) : 0
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-nat-${var.availability_zones[count.index]}"
    }
  )
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nexus.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nexus.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.nexus.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nexus[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-private-rt-${var.availability_zones[count.index]}"
    }
  )
}

# Security Groups
resource "aws_security_group" "nexus_mcp" {
  name_prefix = "${var.environment}-nexus-mcp-"
  vpc_id      = aws_vpc.nexus.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-mcp-sg"
    }
  )
}

resource "aws_security_group" "mongodb" {
  name_prefix = "${var.environment}-nexus-mongodb-"
  vpc_id      = aws_vpc.nexus.id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.nexus_mcp.id, aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-mongodb-sg"
    }
  )
}
```

### EKS Module

```hcl
# infrastructure/terraform/modules/eks/main.tf
resource "aws_eks_cluster" "nexus" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = var.tags
}

resource "aws_eks_node_group" "nexus" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.nexus.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [var.bastion_security_group_id]
  }

  labels = each.value.labels

  taints = each.value.taints

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

# OIDC Provider for IRSA
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.nexus.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.nexus.identity[0].oidc[0].issuer
}

# EKS Add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.nexus.name
  addon_name               = "vpc-cni"
  addon_version            = var.addon_versions.vpc_cni
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.vpc_cni.arn
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.nexus.name
  addon_name        = "coredns"
  addon_version     = var.addon_versions.coredns
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.nexus.name
  addon_name        = "kube-proxy"
  addon_version     = var.addon_versions.kube_proxy
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.nexus.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addon_versions.aws_ebs_csi_driver
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
}
```

### MongoDB Infrastructure

```hcl
# infrastructure/terraform/modules/mongodb/main.tf
resource "aws_instance" "mongodb" {
  count = var.replica_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.ssh_key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = var.data_volume_size
    iops        = var.data_volume_iops
    throughput  = var.data_volume_throughput
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    replica_set_name = var.replica_set_name
    node_index       = count.index
    is_arbiter       = count.index == var.replica_count - 1
    admin_password   = random_password.admin.result
  })

  tags = merge(
    var.tags,
    {
      Name     = "${var.environment}-nexus-mongodb-${count.index}"
      Role     = count.index == var.replica_count - 1 ? "arbiter" : (count.index == 0 ? "primary" : "secondary")
      ReplicaSet = var.replica_set_name
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }
}

# Route53 Records
resource "aws_route53_record" "mongodb" {
  count = var.replica_count

  zone_id = var.private_zone_id
  name    = "mongodb-${count.index}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.mongodb[count.index].private_ip]
}

resource "aws_route53_record" "mongodb_srv" {
  zone_id = var.private_zone_id
  name    = "_mongodb._tcp.${var.domain_name}"
  type    = "SRV"
  ttl     = 300
  
  records = [
    for i in range(var.replica_count) : 
    "0 0 27017 mongodb-${i}.${var.domain_name}"
  ]
}

# Backup Configuration
resource "aws_backup_plan" "mongodb" {
  name = "${var.environment}-nexus-mongodb-backup"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.mongodb.name
    schedule          = "cron(0 2 * * ? *)"
    start_window      = 60
    completion_window = 120

    lifecycle {
      delete_after = 30
    }

    recovery_point_tags = var.tags
  }

  rule {
    rule_name         = "weekly_backup"
    target_vault_name = aws_backup_vault.mongodb.name
    schedule          = "cron(0 3 ? * SUN *)"
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after       = 90
      cold_storage_after = 30
    }

    recovery_point_tags = var.tags
  }
}

resource "aws_backup_selection" "mongodb" {
  name         = "${var.environment}-nexus-mongodb-backup-selection"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.mongodb.id

  resources = aws_instance.mongodb[*].arn

  condition {
    string_equals {
      key   = "ReplicaSet"
      value = var.replica_set_name
    }
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "mongodb_cpu" {
  count = var.replica_count

  alarm_name          = "${var.environment}-nexus-mongodb-${count.index}-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "MongoDB instance CPU utilization"

  dimensions = {
    InstanceId = aws_instance.mongodb[count.index].id
  }

  alarm_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "mongodb_disk" {
  count = var.replica_count

  alarm_name          = "${var.environment}-nexus-mongodb-${count.index}-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "MongoDB instance disk usage"

  dimensions = {
    InstanceId = aws_instance.mongodb[count.index].id
    device     = "/dev/sdf"
    fstype     = "xfs"
    path       = "/data"
  }

  alarm_actions = [var.sns_topic_arn]
}
```

### Bastion Host Module

```hcl
# infrastructure/terraform/modules/bastion/main.tf
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    allowed_users = jsonencode(var.allowed_users)
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-bastion"
    }
  )
}

resource "aws_security_group" "bastion" {
  name_prefix = "${var.environment}-nexus-bastion-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-bastion-sg"
    }
  )
}

# Session Manager Configuration
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/aws/ec2/bastion/${var.environment}"
  retention_in_days = 30
  kms_key_id        = var.kms_key_id

  tags = var.tags
}
```

### Environment Configuration

```hcl
# infrastructure/terraform/environments/prod/main.tf
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

locals {
  environment = "prod"
  region      = "us-east-1"
  
  tags = {
    Environment = local.environment
    Project     = "nexus-mcp"
    ManagedBy   = "terraform"
    CostCenter  = "research"
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  environment         = local.environment
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_nat_gateway  = true
  cluster_name        = "${local.environment}-nexus-eks"
  tags                = local.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"
  
  cluster_name            = "${local.environment}-nexus-eks"
  kubernetes_version      = "1.28"
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_subnet_ids      = module.vpc.private_subnet_ids
  bastion_security_group_id = module.bastion.security_group_id
  
  node_groups = {
    general = {
      desired_size   = 3
      min_size       = 3
      max_size       = 10
      instance_types = ["t3.large"]
      disk_size      = 100
      labels = {
        role = "general"
      }
      taints = []
    }
    
    compute = {
      desired_size   = 2
      min_size       = 0
      max_size       = 5
      instance_types = ["c5.2xlarge"]
      disk_size      = 100
      labels = {
        role = "compute"
      }
      taints = [{
        key    = "compute"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }
  
  addon_versions = {
    vpc_cni            = "v1.15.0-eksbuild.2"
    coredns            = "v1.10.1-eksbuild.5"
    kube_proxy         = "v1.28.2-eksbuild.2"
    aws_ebs_csi_driver = "v1.24.0-eksbuild.1"
  }
  
  tags = local.tags
}

# MongoDB Module
module "mongodb" {
  source = "../../modules/mongodb"
  
  environment             = local.environment
  replica_count           = 5  # 3 data nodes + 1 secondary + 1 arbiter
  instance_type           = "r6i.xlarge"
  root_volume_size        = 50
  data_volume_size        = 500
  data_volume_iops        = 3000
  data_volume_throughput  = 250
  subnet_ids              = module.vpc.database_subnet_ids
  security_group_id       = module.vpc.mongodb_security_group_id
  ssh_key_name            = var.ssh_key_name
  kms_key_id              = module.kms.key_id
  private_zone_id         = aws_route53_zone.private.zone_id
  domain_name             = "nexus.internal"
  replica_set_name        = "nexusResearchRS"
  sns_topic_arn           = module.monitoring.sns_topic_arn
  tags                    = local.tags
}

# Bastion Host Module
module "bastion" {
  source = "../../modules/bastion"
  
  environment       = local.environment
  instance_type     = "t3.micro"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  ssh_key_name      = var.ssh_key_name
  allowed_cidrs     = var.bastion_allowed_cidrs
  allowed_users     = var.bastion_allowed_users
  kms_key_id        = module.kms.key_id
  tags              = local.tags
}
```

## Docker Compose for Local Development

### Main Docker Compose Configuration

```yaml
# docker-compose.yml
version: '3.8'

x-common-variables: &common-variables
  NODE_ENV: development
  LOG_LEVEL: debug
  TZ: UTC

services:
  # MongoDB Replica Set
  mongodb-primary:
    image: mongo:7.0
    container_name: nexus-mongodb-primary
    command: mongod --replSet nexusRS --bind_ip_all
    environment:
      <<: *common-variables
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD:-localdev}
      MONGO_INITDB_DATABASE: nexus_research
    volumes:
      - mongodb-primary-data:/data/db
      - ./scripts/mongo-init:/docker-entrypoint-initdb.d:ro
    ports:
      - "27017:27017"
    networks:
      nexus-network:
        aliases:
          - mongodb-primary.local
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 10s
      retries: 5
      start_period: 40s

  mongodb-secondary:
    image: mongo:7.0
    container_name: nexus-mongodb-secondary
    command: mongod --replSet nexusRS --bind_ip_all
    environment:
      <<: *common-variables
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD:-localdev}
    volumes:
      - mongodb-secondary-data:/data/db
    ports:
      - "27018:27017"
    networks:
      nexus-network:
        aliases:
          - mongodb-secondary.local
    depends_on:
      - mongodb-primary

  mongodb-arbiter:
    image: mongo:7.0
    container_name: nexus-mongodb-arbiter
    command: mongod --replSet nexusRS --bind_ip_all
    environment:
      <<: *common-variables
    volumes:
      - mongodb-arbiter-data:/data/db
    ports:
      - "27019:27017"
    networks:
      nexus-network:
        aliases:
          - mongodb-arbiter.local
    depends_on:
      - mongodb-primary

  # Replica set initialization
  mongo-setup:
    image: mongo:7.0
    container_name: nexus-mongo-setup
    depends_on:
      - mongodb-primary
      - mongodb-secondary
      - mongodb-arbiter
    volumes:
      - ./scripts/setup-replica-set.js:/setup-replica-set.js:ro
    environment:
      <<: *common-variables
    networks:
      - nexus-network
    command: |
      bash -c '
        sleep 10
        mongosh --host mongodb-primary:27017 -u admin -p ${MONGO_ROOT_PASSWORD:-localdev} --authenticationDatabase admin /setup-replica-set.js
      '

  # MCP Server
  nexus-mcp:
    build:
      context: .
      dockerfile: Dockerfile.dev
      args:
        NODE_VERSION: 20
    container_name: nexus-mcp-server
    environment:
      <<: *common-variables
      MCP_PORT: 3000
      MONGO_URI: mongodb://admin:${MONGO_ROOT_PASSWORD:-localdev}@mongodb-primary:27017,mongodb-secondary:27017/nexus_research?replicaSet=nexusRS&authSource=admin
      REDIS_URL: redis://redis:6379
    volumes:
      - ./src:/app/src:ro
      - ./config:/app/config:ro
      - ./tests:/app/tests:ro
      - node_modules:/app/node_modules
    ports:
      - "3000:3000"
      - "9229:9229" # Node.js debugger
    networks:
      - nexus-network
    depends_on:
      - mongodb-primary
      - redis
    command: npm run dev

  # Redis for caching
  redis:
    image: redis:7-alpine
    container_name: nexus-redis
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    networks:
      - nexus-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Development tools
  mongo-express:
    image: mongo-express:latest
    container_name: nexus-mongo-express
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: ${MONGO_ROOT_PASSWORD:-localdev}
      ME_CONFIG_MONGODB_URL: mongodb://admin:${MONGO_ROOT_PASSWORD:-localdev}@mongodb-primary:27017,mongodb-secondary:27017/nexus_research?replicaSet=nexusRS&authSource=admin
      ME_CONFIG_BASICAUTH_USERNAME: admin
      ME_CONFIG_BASICAUTH_PASSWORD: ${ME_PASSWORD:-admin}
    ports:
      - "8081:8081"
    networks:
      - nexus-network
    depends_on:
      - mongodb-primary

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: nexus-prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    ports:
      - "9090:9090"
    networks:
      - nexus-network

  grafana:
    image: grafana/grafana:latest
    container_name: nexus-grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
      GF_USERS_ALLOW_SIGN_UP: "false"
    volumes:
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning:ro
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards:ro
      - grafana-data:/var/lib/grafana
    ports:
      - "3001:3000"
    networks:
      - nexus-network
    depends_on:
      - prometheus

networks:
  nexus-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

volumes:
  mongodb-primary-data:
  mongodb-secondary-data:
  mongodb-arbiter-data:
  redis-data:
  prometheus-data:
  grafana-data:
  node_modules:
```

### Development Dockerfile

```dockerfile
# Dockerfile.dev
FROM node:20-alpine

WORKDIR /app

# Install development tools
RUN apk add --no-cache \
    bash \
    git \
    openssh-client \
    python3 \
    make \
    g++

# Install global Node.js tools
RUN npm install -g \
    nodemon \
    typescript \
    ts-node \
    @types/node

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Expose ports
EXPOSE 3000 9229

# Development command
CMD ["npm", "run", "dev"]
```

## Kubernetes Manifests for Production

### Namespace and RBAC

```yaml
# k8s/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nexus
  labels:
    name: nexus
    environment: production
---
# k8s/base/service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nexus-mcp
  namespace: nexus
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/nexus-mcp-irsa
---
# k8s/base/rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: nexus-mcp-role
  namespace: nexus
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: nexus-mcp-rolebinding
  namespace: nexus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nexus-mcp-role
subjects:
- kind: ServiceAccount
  name: nexus-mcp
  namespace: nexus
```

### ConfigMaps and Secrets

```yaml
# k8s/base/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nexus-mcp-config
  namespace: nexus
data:
  NODE_ENV: "production"
  MCP_PORT: "3000"
  LOG_LEVEL: "info"
  
  app-config.yaml: |
    server:
      port: 3000
      host: 0.0.0.0
    
    mongodb:
      database: nexus_research
      options:
        poolSize: 100
        connectTimeoutMS: 30000
        serverSelectionTimeoutMS: 5000
    
    mcp:
      protocol:
        version: "1.0"
        capabilities:
          - tools
          - resources
          - prompts
    
    cache:
      ttl: 3600
      maxSize: 1000
---
# k8s/base/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: nexus-mcp-secret
  namespace: nexus
type: Opaque
stringData:
  MONGO_USERNAME: "nexus_prod_user"
  SSH_HOST: "bastion.nexus.internal"
  SSH_USER: "nexus-mcp"
data:
  MONGO_PASSWORD: <base64-encoded-password>
  SSH_PRIVATE_KEY: <base64-encoded-ssh-key>
```

### Deployment with Kustomize

```yaml
# k8s/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus-mcp
  namespace: nexus
  labels:
    app: nexus-mcp
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: nexus-mcp
  template:
    metadata:
      labels:
        app: nexus-mcp
        version: v1
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: nexus-mcp
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - nexus-mcp
              topologyKey: kubernetes.io/hostname
      containers:
      - name: nexus-mcp
        image: nexus-mcp:latest
        imagePullPolicy: Always
        ports:
        - name: http
          containerPort: 3000
          protocol: TCP
        - name: metrics
          containerPort: 9090
          protocol: TCP
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: nexus-mcp-config
              key: NODE_ENV
        - name: MONGO_USERNAME
          valueFrom:
            secretKeyRef:
              name: nexus-mcp-secret
              key: MONGO_USERNAME
        - name: MONGO_PASSWORD
          valueFrom:
            secretKeyRef:
              name: nexus-mcp-secret
              key: MONGO_PASSWORD
        volumeMounts:
        - name: config
          mountPath: /app/config
          readOnly: true
        - name: ssh-key
          mountPath: /app/.ssh
          readOnly: true
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        livenessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          readOnlyRootFilesystem: true
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
      - name: ssh-tunnel
        image: nexus-ssh-tunnel:latest
        env:
        - name: SSH_HOST
          valueFrom:
            secretKeyRef:
              name: nexus-mcp-secret
              key: SSH_HOST
        - name: MONGO_HOST
          value: "mongodb.nexus.internal"
        - name: LOCAL_PORT
          value: "27017"
        volumeMounts:
        - name: ssh-key
          mountPath: /home/tunnel/.ssh
          readOnly: true
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          readOnlyRootFilesystem: true
      volumes:
      - name: config
        configMap:
          name: nexus-mcp-config
      - name: ssh-key
        secret:
          secretName: nexus-mcp-secret
          defaultMode: 0400
          items:
          - key: SSH_PRIVATE_KEY
            path: id_rsa
```

### Kustomization Files

```yaml
# k8s/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: nexus

resources:
  - namespace.yaml
  - service-account.yaml
  - rbac.yaml
  - configmap.yaml
  - secret.yaml
  - deployment.yaml
  - service.yaml
  - ingress.yaml
  - hpa.yaml
  - pdb.yaml
  - networkpolicy.yaml

commonLabels:
  app.kubernetes.io/name: nexus-mcp
  app.kubernetes.io/part-of: nexus
  app.kubernetes.io/managed-by: kustomize

images:
  - name: nexus-mcp
    newName: 123456789012.dkr.ecr.us-east-1.amazonaws.com/nexus-mcp
    newTag: latest
  - name: nexus-ssh-tunnel
    newName: 123456789012.dkr.ecr.us-east-1.amazonaws.com/nexus-ssh-tunnel
    newTag: latest
```

```yaml
# k8s/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: nexus-prod

bases:
  - ../../base

patchesStrategicMerge:
  - deployment-patch.yaml
  - hpa-patch.yaml

configMapGenerator:
  - name: nexus-mcp-config
    behavior: merge
    literals:
      - NODE_ENV=production
      - LOG_LEVEL=warn

secretGenerator:
  - name: nexus-mcp-secret
    behavior: merge
    envs:
      - secrets.env

replicas:
  - name: nexus-mcp
    count: 5

images:
  - name: nexus-mcp
    newTag: v1.2.3
  - name: nexus-ssh-tunnel
    newTag: v1.0.1
```

## Infrastructure Versioning

### Terraform State Management

```hcl
# infrastructure/terraform/environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "nexus-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    dynamodb_table = "nexus-terraform-locks"
    
    workspace_key_prefix = "environments"
  }
}
```

### Version Control Strategy

```bash
#!/bin/bash
# scripts/tag-infrastructure.sh

VERSION=$1
ENVIRONMENT=$2

if [ -z "$VERSION" ] || [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <version> <environment>"
    exit 1
fi

# Tag Terraform modules
git tag -a "terraform-${ENVIRONMENT}-${VERSION}" -m "Terraform ${ENVIRONMENT} infrastructure v${VERSION}"

# Tag Kubernetes manifests
git tag -a "k8s-${ENVIRONMENT}-${VERSION}" -m "Kubernetes ${ENVIRONMENT} manifests v${VERSION}"

# Tag Docker images
docker tag nexus-mcp:latest "nexus-mcp:${VERSION}"
docker tag nexus-ssh-tunnel:latest "nexus-ssh-tunnel:${VERSION}"

# Push tags
git push origin --tags

echo "Infrastructure tagged as version ${VERSION} for ${ENVIRONMENT}"
```

## State Management

### Terraform State Backup

```bash
#!/bin/bash
# scripts/backup-terraform-state.sh

BUCKET="nexus-terraform-state"
BACKUP_BUCKET="nexus-terraform-state-backup"
DATE=$(date +%Y%m%d_%H%M%S)

# List all state files
aws s3 ls s3://${BUCKET} --recursive | grep tfstate | while read -r line; do
    FILE=$(echo $line | awk '{print $4}')
    
    # Copy to backup bucket with timestamp
    aws s3 cp "s3://${BUCKET}/${FILE}" "s3://${BACKUP_BUCKET}/${DATE}/${FILE}"
done

# Create state snapshot
aws s3 sync s3://${BUCKET} s3://${BACKUP_BUCKET}/latest/ --delete

echo "Terraform state backed up to s3://${BACKUP_BUCKET}/${DATE}/"
```

### State Migration

```hcl
# scripts/migrate-state.tf
# Example: Moving resources between modules

moved {
  from = aws_instance.old_mongodb
  to   = module.mongodb.aws_instance.mongodb[0]
}

moved {
  from = aws_security_group.old_mongodb_sg
  to   = module.vpc.aws_security_group.mongodb
}
```

## Disaster Recovery Procedures

### Infrastructure Recovery Runbook

```bash
#!/bin/bash
# scripts/disaster-recovery-infrastructure.sh

ENVIRONMENT=$1
RECOVERY_POINT=$2

echo "=== Infrastructure Disaster Recovery ==="
echo "Environment: $ENVIRONMENT"
echo "Recovery Point: $RECOVERY_POINT"

# 1. Restore Terraform state
echo "Restoring Terraform state..."
aws s3 cp "s3://nexus-terraform-state-backup/${RECOVERY_POINT}/terraform.tfstate" \
          "s3://nexus-terraform-state/${ENVIRONMENT}/terraform.tfstate"

# 2. Verify infrastructure
cd infrastructure/terraform/environments/${ENVIRONMENT}
terraform init
terraform plan

# 3. Apply if needed
read -p "Apply infrastructure changes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -auto-approve
fi

# 4. Restore Kubernetes resources
echo "Restoring Kubernetes resources..."
kubectl apply -k k8s/overlays/${ENVIRONMENT}

# 5. Verify services
./scripts/verify-infrastructure.sh ${ENVIRONMENT}

echo "Infrastructure recovery completed"
```

### Backup and Restore Procedures

```yaml
# k8s/cronjobs/backup.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: infrastructure-backup
  namespace: nexus
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: backup-operator
          containers:
          - name: backup
            image: nexus-backup:latest
            command:
            - /bin/bash
            - -c
            - |
              # Backup Kubernetes resources
              kubectl get all,cm,secret,pvc -n nexus -o yaml > /backup/k8s-resources.yaml
              
              # Backup etcd
              ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-snapshot.db
              
              # Upload to S3
              aws s3 cp /backup/ s3://nexus-backups/k8s/$(date +%Y%m%d)/ --recursive
          restartPolicy: OnFailure
```

### Multi-Region Failover

```hcl
# infrastructure/terraform/modules/multi-region/main.tf
resource "aws_route53_record" "nexus_mcp" {
  zone_id = var.hosted_zone_id
  name    = "mcp.nexus.example.com"
  type    = "A"
  
  set_identifier = var.region
  
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
  
  failover_routing_policy {
    type = var.region == "us-east-1" ? "PRIMARY" : "SECONDARY"
  }
}

resource "aws_route53_health_check" "nexus_mcp" {
  fqdn              = module.alb.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nexus-mcp-health-check"
    }
  )
}
```

## GitOps Integration

### ArgoCD Application

```yaml
# argocd/nexus-mcp-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nexus-mcp
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: nexus
  
  source:
    repoURL: https://github.com/nexus/nexus-mcp
    targetRevision: HEAD
    path: k8s/overlays/production
  
  destination:
    server: https://kubernetes.default.svc
    namespace: nexus-prod
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

### Flux CD Configuration

```yaml
# flux/clusters/production/nexus-mcp.yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: nexus-mcp
  namespace: flux-system
spec:
  interval: 1m
  ref:
    branch: main
  url: https://github.com/nexus/nexus-mcp
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: nexus-mcp
  namespace: flux-system
spec:
  interval: 10m
  path: "./k8s/overlays/production"
  prune: true
  sourceRef:
    kind: GitRepository
    name: nexus-mcp
  validation: client
  postBuild:
    substitute:
      cluster_name: "prod-cluster"
      region: "us-east-1"
```