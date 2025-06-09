# Optimize Container Prompt

When optimizing Docker containers, only optimize when you have a specific need:

## 1. When to Optimize

Optimize only when you observe:
- Image size is causing deployment issues (>500MB)
- Build times are impacting development (>5 minutes)
- Security scan flagging vulnerabilities
- Production performance issues traced to container

## 2. Optimization Strategies

### Image Size Reduction
If image size is the issue:
1. Switch to multi-stage builds (`dockerfile-multistage`)
2. Use alpine-based images
3. Remove build dependencies
4. Clear package manager caches

### Build Time Improvement
If build time is the issue:
1. Order Dockerfile commands by change frequency
2. Leverage layer caching properly
3. Use .dockerignore effectively
4. Consider build cache mounts

### Security Hardening
If security is the concern:
1. Run as non-root user
2. Use minimal base images
3. Remove unnecessary tools
4. Scan for vulnerabilities

### Performance Tuning
If runtime performance is the issue:
1. Set appropriate resource limits
2. Configure health checks
3. Optimize startup time
4. Use init systems for signal handling

## 3. Measurement First

Before optimizing:
```bash
# Measure current state
docker images myapp --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
time docker build -t myapp .
docker stats myapp
```

## 4. Progressive Optimization

1. Start with working minimal container
2. Identify specific bottleneck
3. Apply targeted optimization
4. Measure improvement
5. Document why optimization was needed

Remember: Premature optimization adds complexity without benefit!