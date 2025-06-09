# Logging and Monitoring Standards

This document outlines the logging and monitoring standards for the Nexus MCP MongoDB integration project.

## Table of Contents

1. [Structured Logging Format](#structured-logging-format)
2. [Log Levels and Usage](#log-levels-and-usage)
3. [Correlation IDs and Request Tracing](#correlation-ids-and-request-tracing)
4. [Performance Metrics](#performance-metrics)
5. [Error Tracking Requirements](#error-tracking-requirements)
6. [Monitoring Dashboard Standards](#monitoring-dashboard-standards)

## Structured Logging Format

### JSON Log Structure

All logs must be in structured JSON format for easy parsing and analysis:

```typescript
interface LogEntry {
  timestamp: string;          // ISO 8601 format
  level: LogLevel;           // debug, info, warn, error, fatal
  message: string;           // Human-readable message
  service: string;           // Service name (e.g., "mcp-server")
  environment: string;       // dev, staging, production
  correlationId?: string;    // Request correlation ID
  userId?: string;           // User ID if authenticated
  organizationId?: string;   // Organization context
  traceId?: string;          // Distributed trace ID
  spanId?: string;           // Span ID for distributed tracing
  context?: LogContext;      // Additional structured data
  error?: ErrorContext;      // Error details if applicable
  performance?: PerfContext; // Performance metrics
}

interface LogContext {
  action: string;           // What action was performed
  resource?: string;        // Resource being accessed
  method?: string;          // HTTP method or operation type
  path?: string;           // API path or operation path
  query?: Record<string, any>; // Query parameters (sanitized)
  metadata?: Record<string, any>; // Additional metadata
}

interface ErrorContext {
  name: string;            // Error name/type
  message: string;         // Error message
  stack?: string;          // Stack trace (dev/staging only)
  code?: string;          // Error code
  statusCode?: number;    // HTTP status code
  details?: Record<string, any>; // Additional error details
}

interface PerfContext {
  duration: number;        // Operation duration in ms
  memoryUsage?: number;   // Memory usage in MB
  cpuUsage?: number;      // CPU usage percentage
  dbQueryTime?: number;   // Database query time in ms
  externalApiTime?: number; // External API call time
}
```

### Winston Logger Configuration

```typescript
// src/utils/logger.ts
import winston from 'winston';
import { Request } from 'express';

const isDevelopment = process.env.NODE_ENV === 'development';
const isProduction = process.env.NODE_ENV === 'production';

// Custom format for structured logging
const structuredFormat = winston.format.printf(({ 
  level, 
  message, 
  timestamp, 
  ...metadata 
}) => {
  const log: LogEntry = {
    timestamp,
    level,
    message,
    service: process.env.SERVICE_NAME || 'mcp-server',
    environment: process.env.NODE_ENV || 'development',
    ...metadata
  };
  
  return JSON.stringify(log);
});

// Create logger instance
export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
    winston.format.errors({ stack: !isProduction }),
    structuredFormat
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME || 'mcp-server',
    environment: process.env.NODE_ENV || 'development'
  },
  transports: [
    // Console output
    new winston.transports.Console({
      format: isDevelopment 
        ? winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
          )
        : structuredFormat
    }),
    
    // File output for errors
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 10485760, // 10MB
      maxFiles: 5,
      tailable: true
    }),
    
    // File output for all logs
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 10485760, // 10MB
      maxFiles: 10,
      tailable: true
    })
  ]
});

// Add request context to logger
export function createRequestLogger(req: Request): winston.Logger {
  return logger.child({
    correlationId: req.headers['x-correlation-id'],
    userId: req.user?.id,
    organizationId: req.user?.organizationId,
    method: req.method,
    path: req.path,
    ip: req.ip
  });
}
```

### Logging Helper Functions

```typescript
// src/utils/logging-helpers.ts
import { logger } from './logger';
import { performance } from 'perf_hooks';

// Log with performance metrics
export async function logWithPerformance<T>(
  operation: string,
  fn: () => Promise<T>,
  context?: Record<string, any>
): Promise<T> {
  const startTime = performance.now();
  const startMemory = process.memoryUsage().heapUsed / 1024 / 1024;
  
  try {
    const result = await fn();
    const duration = performance.now() - startTime;
    const memoryUsed = process.memoryUsage().heapUsed / 1024 / 1024 - startMemory;
    
    logger.info(`${operation} completed`, {
      context: {
        action: operation,
        ...context
      },
      performance: {
        duration: Math.round(duration),
        memoryUsage: Math.round(memoryUsed * 100) / 100
      }
    });
    
    return result;
  } catch (error) {
    const duration = performance.now() - startTime;
    
    logger.error(`${operation} failed`, {
      context: {
        action: operation,
        ...context
      },
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack
      },
      performance: {
        duration: Math.round(duration)
      }
    });
    
    throw error;
  }
}

// Sanitize sensitive data
export function sanitizeLogData(data: any): any {
  const sensitive = ['password', 'token', 'apiKey', 'secret', 'authorization'];
  
  if (typeof data !== 'object' || data === null) {
    return data;
  }
  
  const sanitized = Array.isArray(data) ? [...data] : { ...data };
  
  Object.keys(sanitized).forEach(key => {
    if (sensitive.some(s => key.toLowerCase().includes(s))) {
      sanitized[key] = '[REDACTED]';
    } else if (typeof sanitized[key] === 'object') {
      sanitized[key] = sanitizeLogData(sanitized[key]);
    }
  });
  
  return sanitized;
}
```

## Log Levels and Usage

### Log Level Guidelines

```typescript
enum LogLevel {
  DEBUG = 'debug',   // Detailed information for debugging
  INFO = 'info',     // General information about app flow
  WARN = 'warn',     // Warning about potential issues
  ERROR = 'error',   // Error that needs attention
  FATAL = 'fatal'    // Critical error requiring immediate action
}
```

### When to Use Each Level

#### DEBUG Level
```typescript
// Use for detailed debugging information
logger.debug('MongoDB query executed', {
  context: {
    action: 'database_query',
    collection: 'signals',
    query: sanitizeLogData(query),
    options: { limit, skip }
  },
  performance: {
    duration: queryTime
  }
});

// Development-only debug logs
if (isDevelopment) {
  logger.debug('Request payload', {
    context: {
      action: 'request_received',
      body: sanitizeLogData(req.body)
    }
  });
}
```

#### INFO Level
```typescript
// Use for general application flow
logger.info('User authenticated successfully', {
  userId: user.id,
  context: {
    action: 'user_login',
    method: 'oauth',
    provider: 'google'
  }
});

logger.info('Signal detection completed', {
  context: {
    action: 'signal_detection',
    trialId: trial.id,
    signalsFound: signals.length
  },
  performance: {
    duration: processingTime,
    dataPoints: dataPointCount
  }
});
```

#### WARN Level
```typescript
// Use for warnings about potential issues
logger.warn('High memory usage detected', {
  context: {
    action: 'system_monitoring',
    threshold: 80,
    current: 85
  },
  performance: {
    memoryUsage: memoryUsagePercent,
    heapUsed: heapUsedMB
  }
});

logger.warn('Retry attempt for MongoDB connection', {
  context: {
    action: 'database_connection',
    attempt: retryCount,
    maxAttempts: maxRetries
  }
});
```

#### ERROR Level
```typescript
// Use for errors that need attention
logger.error('Failed to process signal detection', {
  trialId: trial.id,
  error: {
    name: error.name,
    message: error.message,
    code: error.code,
    stack: error.stack
  },
  context: {
    action: 'signal_detection_error',
    stage: 'data_validation'
  }
});

logger.error('Database transaction failed', {
  error: {
    name: error.name,
    message: error.message,
    code: error.code
  },
  context: {
    action: 'database_transaction',
    operation: 'bulk_insert',
    collection: 'signals'
  }
});
```

#### FATAL Level
```typescript
// Use for critical errors requiring immediate action
logger.fatal('Database connection lost', {
  error: {
    name: error.name,
    message: error.message
  },
  context: {
    action: 'database_connection_lost',
    service: 'mongodb',
    impact: 'service_unavailable'
  }
});

logger.fatal('Critical security breach detected', {
  context: {
    action: 'security_breach',
    type: 'unauthorized_access',
    severity: 'critical'
  },
  userId: attemptedUserId,
  ip: req.ip
});
```

## Correlation IDs and Request Tracing

### Correlation ID Implementation

```typescript
// src/middleware/correlation-id.ts
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

declare global {
  namespace Express {
    interface Request {
      correlationId: string;
    }
  }
}

export function correlationIdMiddleware(
  req: Request, 
  res: Response, 
  next: NextFunction
): void {
  // Use existing correlation ID or generate new one
  const correlationId = req.headers['x-correlation-id'] as string || uuidv4();
  
  // Attach to request and response
  req.correlationId = correlationId;
  res.setHeader('X-Correlation-ID', correlationId);
  
  // Create child logger with correlation ID
  req.logger = logger.child({ correlationId });
  
  next();
}
```

### Distributed Tracing

```typescript
// src/utils/tracing.ts
import { Tracer, Span, SpanContext } from 'opentracing';
import jaeger from 'jaeger-client';

// Initialize Jaeger tracer
const config = {
  serviceName: 'nexus-mcp-server',
  sampler: {
    type: 'const',
    param: 1,
  },
  reporter: {
    logSpans: true,
    agentHost: process.env.JAEGER_AGENT_HOST || 'localhost',
    agentPort: process.env.JAEGER_AGENT_PORT || 6832,
  },
};

const tracer = jaeger.initTracer(config, {});

// Tracing middleware
export function tracingMiddleware(
  req: Request, 
  res: Response, 
  next: NextFunction
): void {
  const spanContext = tracer.extract(jaeger.FORMAT_HTTP_HEADERS, req.headers);
  const span = tracer.startSpan(req.path, {
    childOf: spanContext,
    tags: {
      [jaeger.Tags.SPAN_KIND]: jaeger.Tags.SPAN_KIND_RPC_SERVER,
      [jaeger.Tags.HTTP_METHOD]: req.method,
      [jaeger.Tags.HTTP_URL]: req.url,
      'correlation.id': req.correlationId,
      'user.id': req.user?.id,
    },
  });
  
  // Attach span to request
  req.span = span;
  
  // Log span info
  req.logger.info('Request started', {
    traceId: span.context().toTraceId(),
    spanId: span.context().toSpanId(),
  });
  
  // Finish span on response
  const originalSend = res.send;
  res.send = function(data: any): Response {
    span.setTag(jaeger.Tags.HTTP_STATUS_CODE, res.statusCode);
    span.finish();
    return originalSend.call(this, data);
  };
  
  next();
}

// Helper to create child spans
export function createChildSpan(
  parentSpan: Span, 
  operationName: string
): Span {
  return tracer.startSpan(operationName, {
    childOf: parentSpan,
  });
}
```

### Cross-Service Request Propagation

```typescript
// src/utils/http-client.ts
import axios, { AxiosInstance } from 'axios';

export function createHttpClient(
  baseURL: string,
  correlationId?: string,
  span?: Span
): AxiosInstance {
  const client = axios.create({
    baseURL,
    timeout: 30000,
  });
  
  // Add correlation ID and tracing headers
  client.interceptors.request.use((config) => {
    if (correlationId) {
      config.headers['X-Correlation-ID'] = correlationId;
    }
    
    if (span) {
      const headers = {};
      tracer.inject(span.context(), jaeger.FORMAT_HTTP_HEADERS, headers);
      Object.assign(config.headers, headers);
    }
    
    // Log outgoing request
    logger.info('Outgoing HTTP request', {
      correlationId,
      context: {
        action: 'http_request',
        method: config.method,
        url: config.url,
        baseURL: config.baseURL,
      }
    });
    
    return config;
  });
  
  // Log response
  client.interceptors.response.use(
    (response) => {
      logger.info('HTTP response received', {
        correlationId,
        context: {
          action: 'http_response',
          status: response.status,
          url: response.config.url,
        }
      });
      return response;
    },
    (error) => {
      logger.error('HTTP request failed', {
        correlationId,
        error: {
          message: error.message,
          code: error.code,
          status: error.response?.status,
        },
        context: {
          action: 'http_error',
          url: error.config?.url,
        }
      });
      throw error;
    }
  );
  
  return client;
}
```

## Performance Metrics

### Application Metrics

```typescript
// src/utils/metrics.ts
import { Registry, Counter, Histogram, Gauge } from 'prom-client';

// Create metrics registry
export const metricsRegistry = new Registry();

// HTTP metrics
export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
  registers: [metricsRegistry],
});

export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [metricsRegistry],
});

// Database metrics
export const dbQueryDuration = new Histogram({
  name: 'db_query_duration_seconds',
  help: 'Duration of database queries in seconds',
  labelNames: ['operation', 'collection'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [metricsRegistry],
});

export const dbConnectionPool = new Gauge({
  name: 'db_connection_pool_size',
  help: 'Number of connections in the pool',
  labelNames: ['state'], // active, idle, waiting
  registers: [metricsRegistry],
});

// Business metrics
export const signalDetectionDuration = new Histogram({
  name: 'signal_detection_duration_seconds',
  help: 'Duration of signal detection processing',
  labelNames: ['trial_id', 'algorithm'],
  buckets: [1, 5, 10, 30, 60, 120],
  registers: [metricsRegistry],
});

export const signalsDetected = new Counter({
  name: 'signals_detected_total',
  help: 'Total number of signals detected',
  labelNames: ['trial_id', 'severity', 'type'],
  registers: [metricsRegistry],
});

// System metrics
export const memoryUsage = new Gauge({
  name: 'nodejs_memory_usage_bytes',
  help: 'Node.js memory usage',
  labelNames: ['type'], // rss, heapTotal, heapUsed, external
  registers: [metricsRegistry],
});

// Collect default metrics
import { collectDefaultMetrics } from 'prom-client';
collectDefaultMetrics({ register: metricsRegistry });
```

### Metrics Middleware

```typescript
// src/middleware/metrics.ts
import { Request, Response, NextFunction } from 'express';
import { httpRequestDuration, httpRequestTotal } from '../utils/metrics';

export function metricsMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path;
    const labels = {
      method: req.method,
      route,
      status_code: res.statusCode.toString(),
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
    
    // Log slow requests
    if (duration > 1) {
      logger.warn('Slow request detected', {
        correlationId: req.correlationId,
        context: {
          action: 'slow_request',
          method: req.method,
          path: req.path,
          route,
        },
        performance: {
          duration: Math.round(duration * 1000),
        }
      });
    }
  });
  
  next();
}

// Metrics endpoint
export function metricsEndpoint(req: Request, res: Response): void {
  res.set('Content-Type', metricsRegistry.contentType);
  res.end(await metricsRegistry.metrics());
}
```

### Database Performance Monitoring

```typescript
// src/utils/db-monitoring.ts
import { MongoClient } from 'mongodb';
import { dbQueryDuration, dbConnectionPool } from './metrics';

export function instrumentMongoClient(client: MongoClient): void {
  // Monitor command execution
  client.on('commandStarted', (event) => {
    event.startTime = Date.now();
  });
  
  client.on('commandSucceeded', (event) => {
    const duration = (Date.now() - event.startTime) / 1000;
    dbQueryDuration.observe({
      operation: event.commandName,
      collection: event.command.collection || 'unknown',
    }, duration);
    
    logger.debug('MongoDB query executed', {
      context: {
        action: 'db_query',
        operation: event.commandName,
        collection: event.command.collection,
        requestId: event.requestId,
      },
      performance: {
        duration: Math.round(duration * 1000),
      }
    });
  });
  
  client.on('commandFailed', (event) => {
    logger.error('MongoDB query failed', {
      error: {
        message: event.failure.message,
        code: event.failure.code,
      },
      context: {
        action: 'db_query_error',
        operation: event.commandName,
        collection: event.command.collection,
        requestId: event.requestId,
      }
    });
  });
  
  // Monitor connection pool
  setInterval(() => {
    const poolStats = client.poolStats();
    dbConnectionPool.set({ state: 'active' }, poolStats.inUse);
    dbConnectionPool.set({ state: 'idle' }, poolStats.available);
    dbConnectionPool.set({ state: 'waiting' }, poolStats.pending);
  }, 30000);
}
```

## Error Tracking Requirements

### Error Classification

```typescript
// src/errors/error-types.ts
export enum ErrorSeverity {
  LOW = 'low',        // Can be ignored
  MEDIUM = 'medium',  // Should be investigated
  HIGH = 'high',      // Needs prompt attention
  CRITICAL = 'critical' // Requires immediate action
}

export class BaseError extends Error {
  public readonly isOperational: boolean;
  public readonly severity: ErrorSeverity;
  public readonly code: string;
  public readonly statusCode: number;
  public readonly context?: Record<string, any>;
  
  constructor(
    message: string,
    code: string,
    statusCode: number = 500,
    isOperational: boolean = true,
    severity: ErrorSeverity = ErrorSeverity.MEDIUM,
    context?: Record<string, any>
  ) {
    super(message);
    this.name = this.constructor.name;
    this.code = code;
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.severity = severity;
    this.context = context;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Specific error types
export class ValidationError extends BaseError {
  constructor(message: string, field?: string) {
    super(
      message,
      'VALIDATION_ERROR',
      400,
      true,
      ErrorSeverity.LOW,
      { field }
    );
  }
}

export class AuthenticationError extends BaseError {
  constructor(message: string, attemptedUserId?: string) {
    super(
      message,
      'AUTHENTICATION_ERROR',
      401,
      true,
      ErrorSeverity.HIGH,
      { attemptedUserId }
    );
  }
}

export class DatabaseError extends BaseError {
  constructor(message: string, operation?: string, collection?: string) {
    super(
      message,
      'DATABASE_ERROR',
      503,
      true,
      ErrorSeverity.HIGH,
      { operation, collection }
    );
  }
}
```

### Error Tracking Integration

```typescript
// src/utils/error-tracking.ts
import * as Sentry from '@sentry/node';
import { BaseError } from '../errors/error-types';

// Initialize Sentry
export function initializeErrorTracking(): void {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV,
    tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
    beforeSend(event, hint) {
      // Filter out operational errors in production
      if (process.env.NODE_ENV === 'production') {
        const error = hint.originalException;
        if (error instanceof BaseError && error.isOperational) {
          return null;
        }
      }
      return event;
    },
    integrations: [
      new Sentry.Integrations.Http({ tracing: true }),
      new Sentry.Integrations.Express({ app }),
    ],
  });
}

// Error tracking middleware
export function errorTrackingMiddleware(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  // Log error
  logger.error('Request error', {
    correlationId: req.correlationId,
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
      code: (error as any).code,
    },
    context: {
      action: 'request_error',
      method: req.method,
      path: req.path,
      userId: req.user?.id,
    }
  });
  
  // Track in Sentry
  if (!(error instanceof BaseError) || !error.isOperational) {
    Sentry.withScope((scope) => {
      scope.setTag('correlation_id', req.correlationId);
      scope.setUser({
        id: req.user?.id,
        organization: req.user?.organizationId,
      });
      scope.setContext('request', {
        method: req.method,
        path: req.path,
        query: req.query,
      });
      Sentry.captureException(error);
    });
  }
  
  // Send response
  const statusCode = (error as any).statusCode || 500;
  const response = {
    error: {
      message: error.message,
      code: (error as any).code || 'INTERNAL_ERROR',
      correlationId: req.correlationId,
    }
  };
  
  if (process.env.NODE_ENV !== 'production') {
    response.error.stack = error.stack;
  }
  
  res.status(statusCode).json(response);
}
```

### Error Alerting Rules

```yaml
# alerting-rules.yml
groups:
  - name: error_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"
          
      - alert: CriticalErrorSpike
        expr: rate(app_errors_total{severity="critical"}[1m]) > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Critical error detected"
          description: "Critical error in {{ $labels.service }}"
          
      - alert: DatabaseConnectionFailure
        expr: up{job="mongodb"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection lost"
          description: "MongoDB is not responding"
```

## Monitoring Dashboard Standards

### Grafana Dashboard Structure

```json
{
  "dashboard": {
    "title": "Nexus MCP Monitoring",
    "tags": ["nexus", "mcp", "monitoring"],
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ]
      },
      {
        "title": "Response Time P95",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status_code=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          }
        ]
      },
      {
        "title": "Signal Detection Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(signal_detection_duration_seconds_sum[5m]) / rate(signal_detection_duration_seconds_count[5m])",
            "legendFormat": "Avg detection time"
          }
        ]
      }
    ]
  }
}
```

### Key Metrics to Monitor

```typescript
// Dashboard configuration
export const dashboardConfig = {
  // System Health
  systemHealth: {
    cpuUsage: 'process_cpu_user_seconds_total',
    memoryUsage: 'process_resident_memory_bytes',
    gcPause: 'nodejs_gc_duration_seconds',
    eventLoopLag: 'nodejs_eventloop_lag_seconds',
  },
  
  // Application Performance
  performance: {
    requestRate: 'rate(http_requests_total[5m])',
    responseTime: {
      p50: 'histogram_quantile(0.5, http_request_duration_seconds_bucket)',
      p95: 'histogram_quantile(0.95, http_request_duration_seconds_bucket)',
      p99: 'histogram_quantile(0.99, http_request_duration_seconds_bucket)',
    },
    errorRate: 'rate(http_requests_total{status_code=~"5.."}[5m])',
  },
  
  // Database Performance
  database: {
    queryTime: 'db_query_duration_seconds',
    connectionPool: 'db_connection_pool_size',
    slowQueries: 'db_query_duration_seconds > 1',
  },
  
  // Business Metrics
  business: {
    signalsDetected: 'rate(signals_detected_total[1h])',
    detectionTime: 'signal_detection_duration_seconds',
    activeTrials: 'gauge_active_trials',
    userActivity: 'rate(user_actions_total[5m])',
  },
};
```

### Alert Dashboard

```typescript
// Alert status dashboard
export const alertDashboard = {
  panels: [
    {
      title: "Active Alerts",
      query: "ALERTS{alertstate='firing'}",
      type: "table"
    },
    {
      title: "Alert History",
      query: "ALERTS",
      type: "table"
    },
    {
      title: "Error Trends",
      query: "rate(app_errors_total[1h])",
      type: "heatmap"
    },
    {
      title: "Service Health",
      query: "up",
      type: "stat"
    }
  ]
};
```

### SLO Monitoring

```yaml
# SLO definitions
slos:
  - name: API Availability
    target: 99.9%
    query: |
      1 - (
        rate(http_requests_total{status_code=~"5.."}[30d]) /
        rate(http_requests_total[30d])
      )
      
  - name: Response Time
    target: 95% < 500ms
    query: |
      histogram_quantile(0.95, 
        rate(http_request_duration_seconds_bucket[30d])
      ) < 0.5
      
  - name: Signal Detection Success
    target: 99.5%
    query: |
      1 - (
        rate(signal_detection_errors_total[30d]) /
        rate(signal_detection_attempts_total[30d])
      )
```