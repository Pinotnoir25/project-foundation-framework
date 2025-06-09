# Prompt: Determine Infrastructure Requirements

Use this prompt to analyze technical specifications and determine infrastructure needs.

## Prompt

I need you to determine infrastructure requirements for `[FEATURE/COMPONENT]` based on:
- Technical specifications at: `[TECH_SPEC_PATH]`
- Expected load: `[LOAD_DESCRIPTION]`
- Environment: `[development/staging/production]`

Please create comprehensive infrastructure specifications.

### 1. Analyze Technical Requirements
From the technical specs, identify:
- Application architecture (monolithic, microservices, serverless)
- Technology stack and runtime requirements
- Database and storage needs
- External service dependencies
- Performance requirements
- Security requirements

### 2. Calculate Resource Requirements
Determine needs for:
- **Compute**: CPU cores, memory (RAM)
- **Storage**: Type (SSD/HDD), size, IOPS
- **Network**: Bandwidth, latency requirements
- **Database**: Size, connections, read/write ratios

Use this formula for initial estimates:
```
CPU cores = (requests/sec × avg_processing_time) / core_efficiency
Memory = base_memory + (concurrent_users × memory_per_user)
Storage = data_size × growth_factor × retention_period
```

### 3. Design High Availability
Plan for:
- Multiple availability zones
- Load balancing strategy
- Failover mechanisms
- Data replication
- Backup and recovery

### 4. Define Scaling Strategy
Specify:
- Horizontal scaling triggers and limits
- Vertical scaling options
- Auto-scaling policies
- Database scaling approach
- Caching strategy

### 5. Plan Network Architecture
Design:
- VPC configuration
- Subnet allocation
- Security groups
- Load balancers
- CDN requirements
- VPN/Direct Connect needs

### 6. Specify Container Configuration
If using containers:
- Base images
- Resource limits
- Health checks
- Orchestration (Kubernetes/ECS)
- Service mesh requirements

### 7. Design Monitoring Stack
Include:
- Metrics collection (Prometheus, CloudWatch)
- Log aggregation (ELK, CloudWatch Logs)
- Distributed tracing (Jaeger, X-Ray)
- Alerting rules
- Dashboards

### 8. Plan Security Infrastructure
Cover:
- WAF configuration
- DDoS protection
- Secrets management
- Certificate management
- Network isolation

### 9. Calculate Costs
Estimate monthly costs for:
- Compute instances
- Storage
- Data transfer
- Managed services
- Monitoring tools

### 10. Create Deployment Pipeline
Define:
- CI/CD infrastructure
- Build servers
- Artifact storage
- Deployment automation
- Environment promotion

Save as `docs/technical/infrastructure/[component-name]-infrastructure.md`

## Example Usage

```
@claude determine infrastructure requirements for {{Service Name}} based on technical specs, expecting {{user_count}} concurrent users in production

The assistant will calculate:
- Compute needs for {{processing_type}}
- {{Database}} cluster sizing
- Queue infrastructure for async processing
- Monitoring for performance tracking
```

## Infrastructure Sizing Example

```yaml
# Production Environment - {{Service Name}}

## Compute Requirements
application_servers:
  instance_type: c5.2xlarge (8 vCPU, 16 GB RAM)
  count: 4 (auto-scale 4-12)
  
  calculation:
    - Peak load: 1000 concurrent users
    - Avg processing time: 200ms
    - Requests/sec: 5000
    - CPU needed: (5000 × 0.2) / 0.7 = 1428 CPU units
    - Instances: 1428 / 8 = ~4 instances (with headroom)

worker_nodes:
  instance_type: c5.xlarge (4 vCPU, 8 GB RAM)
  count: 6 (auto-scale 2-20)
  purpose: Background {{processing_type}}
  
## Database Sizing
{{database_type}}_cluster:
  tier: {{tier_name}} (8 vCPU, 32 GB RAM)
  storage: 500 GB SSD
  iops: 3000
  replicas: 3 (1 primary, 2 secondary)
  
  calculation:
    - Active data: 100 GB
    - Growth rate: 10 GB/month
    - Retention: 2 years
    - Total: 100 + (10 × 24) = 340 GB
    - With overhead: 500 GB

## Network Requirements
bandwidth:
  ingress: 100 Mbps sustained, 500 Mbps burst
  egress: 200 Mbps sustained, 1 Gbps burst
  
load_balancer:
  type: Application Load Balancer
  targets: 4-12 instances
  health_check: /health every 15s

## Caching Layer
redis_cluster:
  node_type: cache.r6g.large
  nodes: 3
  memory: 12 GB per node
  purpose: Session cache, API responses
```

## Cost Estimation Template

```markdown
## Monthly Cost Estimate - Production

### Compute Costs
- Application Servers: 4 × c5.2xlarge × $0.34/hr = $979/month
- Worker Nodes: 6 × c5.xlarge × $0.17/hr = $734/month
- Load Balancer: $22/month + $0.008/GB = ~$50/month

### Database Costs
- {{Database}} {{tier}}: ${{db_cost}}/month
- Backup Storage: 500 GB × $0.10/GB = $50/month

### Storage Costs
- EBS Volumes: 2 TB × $0.10/GB = $200/month
- S3 Storage: 1 TB × $0.023/GB = $23/month

### Network Costs
- Data Transfer: 1 TB/month × $0.09/GB = $90/month
- CloudFront CDN: ~$50/month

### Monitoring Costs
- CloudWatch: ~$100/month
- Log Storage: ~$50/month

### Total Estimated Cost: $2,905/month

### Cost Optimization Opportunities
1. Reserved Instances: Save 30% on compute
2. Spot Instances for workers: Save 70%
3. S3 Lifecycle policies: Save 50% on cold storage
4. Potential savings: ~$800/month
```

## Environment Comparison

```yaml
environments:
  development:
    compute: t3.medium (2 vCPU, 4 GB)
    instances: 1
    database: {{Database}} {{dev_tier}}
    cost: ~$80/month
    
  staging:
    compute: t3.large (2 vCPU, 8 GB)
    instances: 2
    database: {{Database}} {{staging_tier}}
    cost: ~$450/month
    
  production:
    compute: c5.2xlarge (8 vCPU, 16 GB)
    instances: 4-12
    database: {{Database}} {{prod_tier}}
    cost: ~$2,905/month
```

## Infrastructure as Code

Also generate Terraform example:

```hcl
# Application Server Auto Scaling Group
resource "aws_autoscaling_group" "app_servers" {
  name                = "{{service-name}}-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  min_size            = 4
  max_size            = 12
  desired_capacity    = 4

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "{{service-name}}-server"
    propagate_at_launch = true
  }
}
```

## Follow-up Prompts

- "Generate Terraform configuration for this infrastructure"
- "Create CloudFormation template for AWS deployment"
- "Design Kubernetes manifests for container deployment"
- "Calculate infrastructure costs for different regions"
- "Create disaster recovery infrastructure plan"