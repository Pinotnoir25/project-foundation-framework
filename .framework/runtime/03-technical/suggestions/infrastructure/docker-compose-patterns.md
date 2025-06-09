# Docker Compose Patterns Template

## Overview
Production-ready Docker Compose configurations for multi-container applications with best practices for development and deployment.

## When to Suggest
- Multi-service applications
- Local development environments
- Integration testing setups
- Small to medium deployments
- Microservices development

## Core Patterns

### Full-Stack Application Pattern
```yaml
version: '3.8'

services:
  # Frontend Service
  frontend:
    build:
      context: ./app/frontend
      dockerfile: Dockerfile
      args:
        - NODE_ENV=development
    container_name: myapp-frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000
      - NODE_ENV=development
    volumes:
      - ./app/frontend:/app
      - /app/node_modules
      - /app/.next
    depends_on:
      - backend
    networks:
      - app-network
    restart: unless-stopped

  # Backend API Service
  backend:
    build:
      context: ./app/backend
      dockerfile: Dockerfile
      target: development
    container_name: myapp-backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET:-development-secret}
      - NODE_ENV=development
    volumes:
      - ./app/backend:/app
      - /app/node_modules
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    restart: unless-stopped
    command: npm run dev

  # PostgreSQL Database
  db:
    image: postgres:16-alpine
    container_name: myapp-db
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    networks:
      - app-network
    restart: unless-stopped

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./app/frontend/out:/usr/share/nginx/html:ro
    depends_on:
      - frontend
      - backend
    networks:
      - app-network
    restart: unless-stopped

  # Background Worker
  worker:
    build:
      context: ./app/backend
      dockerfile: Dockerfile
    container_name: myapp-worker
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./app/backend:/app
    depends_on:
      - db
      - redis
    networks:
      - app-network
    restart: unless-stopped
    command: npm run worker

  # Monitoring - Prometheus
  prometheus:
    image: prom/prometheus:latest
    container_name: myapp-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - app-network
    restart: unless-stopped

  # Monitoring - Grafana
  grafana:
    image: grafana/grafana:latest
    container_name: myapp-grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources:ro
    depends_on:
      - prometheus
    networks:
      - app-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:

networks:
  app-network:
    driver: bridge
```

### Development Overrides Pattern
```yaml
# docker-compose.override.yml
version: '3.8'

services:
  frontend:
    build:
      target: development
    environment:
      - NEXT_TELEMETRY_DISABLED=1
    command: npm run dev
    stdin_open: true
    tty: true

  backend:
    build:
      target: development
    environment:
      - LOG_LEVEL=debug
      - FORCE_COLOR=1
    command: npm run dev:watch

  db:
    ports:
      - "5432:5432"  # Expose for local tools

  # Development-only services
  mailhog:
    image: mailhog/mailhog
    container_name: myapp-mailhog
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI
    networks:
      - app-network

  adminer:
    image: adminer
    container_name: myapp-adminer
    ports:
      - "8080:8080"
    environment:
      - ADMINER_DEFAULT_SERVER=db
    networks:
      - app-network
```

### Production Configuration
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  frontend:
    build:
      target: production
      args:
        - NODE_ENV=production
    environment:
      - NODE_ENV=production
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  backend:
    build:
      target: production
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    restart: always
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

  db:
    environment:
      - POSTGRES_PASSWORD=${DB_PASSWORD:?DB_PASSWORD not set}
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G

  nginx:
    volumes:
      - ./nginx/nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./app/frontend/build:/usr/share/nginx/html:ro
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
```

### Microservices Pattern
```yaml
version: '3.8'

x-common-variables: &common-variables
  LOG_LEVEL: ${LOG_LEVEL:-info}
  JAEGER_ENDPOINT: http://jaeger:14268/api/traces

services:
  # API Gateway
  api-gateway:
    build: ./services/api-gateway
    ports:
      - "8080:8080"
    environment:
      <<: *common-variables
      SERVICES_AUTH_URL: http://auth-service:3001
      SERVICES_USER_URL: http://user-service:3002
      SERVICES_PRODUCT_URL: http://product-service:3003
    depends_on:
      - auth-service
      - user-service
      - product-service
    networks:
      - microservices

  # Auth Service
  auth-service:
    build: ./services/auth
    environment:
      <<: *common-variables
      DATABASE_URL: postgresql://postgres:postgres@auth-db:5432/auth
      REDIS_URL: redis://auth-redis:6379
    depends_on:
      auth-db:
        condition: service_healthy
    networks:
      - microservices

  auth-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: auth
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - auth_db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - microservices

  auth-redis:
    image: redis:7-alpine
    volumes:
      - auth_redis_data:/data
    networks:
      - microservices

  # User Service
  user-service:
    build: ./services/user
    environment:
      <<: *common-variables
      DATABASE_URL: postgresql://postgres:postgres@user-db:5432/users
    depends_on:
      user-db:
        condition: service_healthy
    networks:
      - microservices

  user-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - user_db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - microservices

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: admin
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - microservices

  # Distributed Tracing
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
    networks:
      - microservices

  # Service Discovery
  consul:
    image: consul:latest
    ports:
      - "8500:8500"
    command: agent -server -bootstrap-expect=1 -ui -client=0.0.0.0
    volumes:
      - consul_data:/consul/data
    networks:
      - microservices

volumes:
  auth_db_data:
  auth_redis_data:
  user_db_data:
  rabbitmq_data:
  consul_data:

networks:
  microservices:
    driver: bridge
```

### Testing Environment Pattern
```yaml
# docker-compose.test.yml
version: '3.8'

services:
  test-runner:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@test-db:5432/test
      - REDIS_URL=redis://test-redis:6379
      - NODE_ENV=test
    volumes:
      - ./app:/app
      - ./coverage:/app/coverage
    depends_on:
      test-db:
        condition: service_healthy
      test-redis:
        condition: service_started
    networks:
      - test-network
    command: npm run test:ci

  test-db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=test
    tmpfs:
      - /var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - test-network

  test-redis:
    image: redis:7-alpine
    tmpfs:
      - /data
    networks:
      - test-network

  e2e-tests:
    build:
      context: ./tests/e2e
      dockerfile: Dockerfile
    environment:
      - BASE_URL=http://frontend:3000
      - API_URL=http://backend:8000
    volumes:
      - ./tests/e2e:/tests
      - ./test-results:/test-results
    depends_on:
      - frontend
      - backend
    networks:
      - test-network
    command: npm run test:e2e

networks:
  test-network:
    driver: bridge
```

### Utility Scripts
```bash
#!/bin/bash
# scripts/docker-compose-helper.sh

# Start development environment
dev() {
  docker-compose up -d
  docker-compose logs -f
}

# Start production environment
prod() {
  docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
}

# Run tests
test() {
  docker-compose -f docker-compose.test.yml run --rm test-runner
}

# Clean everything
clean() {
  docker-compose down -v --remove-orphans
  docker system prune -af
}

# Backup databases
backup() {
  timestamp=$(date +%Y%m%d_%H%M%S)
  docker-compose exec db pg_dump -U postgres myapp > "backups/backup_$timestamp.sql"
}

# Execute command
case "$1" in
  dev|prod|test|clean|backup)
    "$1"
    ;;
  *)
    echo "Usage: $0 {dev|prod|test|clean|backup}"
    exit 1
    ;;
esac
```

### Environment Configuration
```env
# .env.example
# Application
NODE_ENV=development
APP_NAME=myapp
APP_URL=http://localhost

# Database
DB_HOST=db
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=postgres

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# JWT
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=7d

# Email (Development)
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USER=
MAIL_PASS=

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
GRAFANA_ADMIN_PASSWORD=admin
```

### Health Check Patterns
```yaml
healthcheck:
  # HTTP health check
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s

  # TCP health check
  test: ["CMD", "nc", "-z", "localhost", "5432"]
  
  # Custom script health check
  test: ["CMD", "/app/scripts/health-check.sh"]
```

## Key Benefits
- Consistent development environments
- Easy service orchestration
- Built-in networking
- Volume management
- Environment configuration
- Health monitoring
- Easy scaling for development

## Best Practices
- Use specific image versions
- Implement health checks
- Separate dev/prod configurations
- Use .env files for secrets
- Implement proper logging
- Use named volumes for data
- Network isolation
- Resource limits in production