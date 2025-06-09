# Deployment Patterns Template

## Overview
Modern deployment patterns for containerized applications covering various cloud platforms and deployment strategies.

## When to Suggest
- Production deployments needed
- Scaling requirements identified
- CI/CD pipeline setup
- Multi-environment management
- High availability requirements

## Core Patterns

### Kubernetes Deployment Pattern
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: myapp-production

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: myapp-production
data:
  NODE_ENV: "production"
  LOG_LEVEL: "info"
  API_URL: "https://api.myapp.com"

---
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: myapp-production
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@postgres:5432/myapp"
  JWT_SECRET: "your-secret-key"

---
# k8s/deployment-backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: myapp-production
  labels:
    app: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: myapp/backend:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
# k8s/service-backend.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: myapp-production
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP

---
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: myapp-production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80

---
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: myapp-production
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
  - hosts:
    - api.myapp.com
    - myapp.com
    secretName: myapp-tls
  rules:
  - host: api.myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 8000
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 3000
```

### GitHub Actions CI/CD Pattern
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '20'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint
    
    - name: Build application
      run: npm run build

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v2
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
        cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Kubernetes
      uses: azure/k8s-deploy@v4
      with:
        namespace: myapp-production
        manifests: |
          k8s/deployment.yaml
          k8s/service.yaml
        images: |
          ${{ needs.build-and-push.outputs.image-tag }}
        
    - name: Wait for rollout
      run: |
        kubectl rollout status deployment/backend -n myapp-production
        kubectl rollout status deployment/frontend -n myapp-production
```

### AWS ECS/Fargate Pattern
```json
// ecs/task-definition.json
{
  "family": "myapp-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "taskRoleArn": "arn:aws:iam::123456789:role/ecsTaskRole",
  "executionRoleArn": "arn:aws:iam::123456789:role/ecsExecutionRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/myapp-backend:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:myapp/db-url"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:myapp/jwt-secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "backend"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

```yaml
# cloudformation/ecs-service.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: ECS Service for MyApp

Parameters:
  VpcId:
    Type: AWS::EC2::VPC::Id
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>
  CertificateArn:
    Type: String

Resources:
  LoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Type: application
      Subnets: !Ref SubnetIds
      SecurityGroups:
        - !Ref LoadBalancerSecurityGroup

  LoadBalancerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for ALB
      VpcId: !Ref VpcId
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      HealthCheckPath: /health
      Port: 8000
      Protocol: HTTP
      TargetType: ip
      VpcId: !Ref VpcId

  HTTPSListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup
      LoadBalancerArn: !Ref LoadBalancer
      Port: 443
      Protocol: HTTPS
      Certificates:
        - CertificateArn: !Ref CertificateArn

  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: myapp-cluster
      CapacityProviders:
        - FARGATE
        - FARGATE_SPOT

  ECSService:
    Type: AWS::ECS::Service
    DependsOn: HTTPSListener
    Properties:
      Cluster: !Ref ECSCluster
      TaskDefinition: !Ref TaskDefinition
      DesiredCount: 3
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          Subnets: !Ref SubnetIds
          SecurityGroups:
            - !Ref ServiceSecurityGroup
      LoadBalancers:
        - ContainerName: backend
          ContainerPort: 8000
          TargetGroupArn: !Ref TargetGroup
      HealthCheckGracePeriodSeconds: 60

  AutoScalingTarget:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10
      MinCapacity: 3
      ResourceId: !Sub 'service/${ECSCluster}/backend'
      RoleARN: !Sub 'arn:aws:iam::${AWS::AccountId}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService'
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs

  AutoScalingPolicy:
    Type: AWS::ApplicationAutoScaling::ScalingPolicy
    Properties:
      PolicyName: ECSScalingPolicy
      PolicyType: TargetTrackingScaling
      ScalingTargetId: !Ref AutoScalingTarget
      TargetTrackingScalingPolicyConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ECSServiceAverageCPUUtilization
        TargetValue: 70.0
```

### Docker Swarm Pattern
```yaml
# docker-stack.yml
version: '3.8'

services:
  frontend:
    image: myapp/frontend:latest
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      placement:
        constraints:
          - node.role == worker
    networks:
      - web
      - internal
    environment:
      - NODE_ENV=production

  backend:
    image: myapp/backend:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    networks:
      - internal
    secrets:
      - db_password
      - jwt_secret
    environment:
      - NODE_ENV=production

  nginx:
    image: nginx:alpine
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == manager
    ports:
      - "80:80"
      - "443:443"
    networks:
      - web
    configs:
      - source: nginx_config
        target: /etc/nginx/nginx.conf
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt:ro

  db:
    image: postgres:16
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.db == true
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

networks:
  web:
    driver: overlay
    attachable: true
  internal:
    driver: overlay
    internal: true

volumes:
  postgres_data:
    driver: local

secrets:
  db_password:
    external: true
  jwt_secret:
    external: true

configs:
  nginx_config:
    file: ./nginx/nginx.conf
```

### Blue-Green Deployment Pattern
```bash
#!/bin/bash
# scripts/blue-green-deploy.sh

set -e

# Configuration
APP_NAME="myapp"
CURRENT_ENV=$(kubectl get service $APP_NAME -o jsonpath='{.spec.selector.version}')
NEW_ENV=$([[ "$CURRENT_ENV" == "blue" ]] && echo "green" || echo "blue")
IMAGE_TAG="${1:-latest}"

echo "Current environment: $CURRENT_ENV"
echo "Deploying to: $NEW_ENV"

# Deploy new version
kubectl set image deployment/$APP_NAME-$NEW_ENV \
  app=$IMAGE_REGISTRY/$APP_NAME:$IMAGE_TAG

# Wait for rollout
kubectl rollout status deployment/$APP_NAME-$NEW_ENV

# Run smoke tests
echo "Running smoke tests..."
./scripts/smoke-tests.sh $NEW_ENV

if [ $? -eq 0 ]; then
  echo "Smoke tests passed. Switching traffic..."
  
  # Switch traffic
  kubectl patch service $APP_NAME \
    -p '{"spec":{"selector":{"version":"'$NEW_ENV'"}}}'
  
  echo "Traffic switched to $NEW_ENV"
  
  # Optional: Scale down old version after verification
  # sleep 300
  # kubectl scale deployment/$APP_NAME-$CURRENT_ENV --replicas=0
else
  echo "Smoke tests failed. Rolling back..."
  kubectl rollout undo deployment/$APP_NAME-$NEW_ENV
  exit 1
fi
```

### Canary Deployment with Istio
```yaml
# istio/virtual-service.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: myapp
spec:
  hosts:
  - myapp.com
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: v2
  - route:
    - destination:
        host: myapp
        subset: v1
      weight: 90
    - destination:
        host: myapp
        subset: v2
      weight: 10

---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: myapp
spec:
  host: myapp
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

### Monitoring and Observability
```yaml
# k8s/monitoring.yaml
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: myapp-metrics
spec:
  selector:
    matchLabels:
      app: myapp
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics

---
# Grafana Dashboard ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "MyApp Metrics",
        "panels": [
          {
            "title": "Request Rate",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])"
              }
            ]
          },
          {
            "title": "Error Rate",
            "targets": [
              {
                "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
              }
            ]
          }
        ]
      }
    }
```

### Terraform Infrastructure
```hcl
# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "myapp-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "myapp-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Environment = "production"
    Application = "myapp"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = "myapp-cluster"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      desired_size = 3
      min_size     = 3
      max_size     = 10

      instance_types = ["t3.medium"]
      
      k8s_labels = {
        Environment = "production"
      }
    }
  }
}
```

## Key Benefits
- Automated deployments
- Zero-downtime updates
- Easy rollbacks
- Scalability
- Infrastructure as Code
- Monitoring integration
- Multi-environment support

## Best Practices
- Use GitOps for deployments
- Implement health checks
- Set resource limits
- Use secrets management
- Implement proper logging
- Monitor key metrics
- Regular backups
- Disaster recovery planning