# API Testing Guide

This guide provides comprehensive testing strategies and patterns for the Nexus MCP MongoDB server APIs, ensuring reliability, performance, and security.

## API Testing Strategies

### Testing Pyramid for APIs

```
                 ┌─────────────┐
                 │   E2E Tests │  (5%)
                 ├─────────────┤
                 │ Integration │  (15%)
                 │    Tests    │
                 ├─────────────┤
                 │  Contract   │  (20%)
                 │    Tests    │
                 ├─────────────┤
                 │    Unit     │  (60%)
                 │    Tests    │
                 └─────────────┘
```

### Test Categories

#### Unit Tests
- Test individual functions and methods
- Mock external dependencies
- Focus on business logic
- Fast execution (< 100ms per test)

#### Contract Tests
- Verify API contracts between services
- Test request/response schemas
- Ensure backward compatibility
- Run on every commit

#### Integration Tests
- Test actual MongoDB interactions
- Verify authentication flows
- Test complete request cycles
- Use test database instances

#### End-to-End Tests
- Test complete user workflows
- Verify cross-service interactions
- Test error scenarios
- Performance under load

### Testing Strategy Matrix

| Test Type | Scope | Speed | Reliability | When to Run |
|-----------|-------|-------|-------------|-------------|
| Unit | Function | Fast | High | Every save |
| Contract | API Schema | Fast | High | Every commit |
| Integration | Service | Medium | Medium | Every PR |
| E2E | System | Slow | Low | Before release |
| Performance | System | Slow | Medium | Nightly |
| Security | System | Slow | High | Weekly |

## Contract Testing with Pact

### Pact Setup
```javascript
// pact.config.js
const path = require('path');

module.exports = {
  consumer: 'nexus-frontend',
  provider: 'nexus-mcp-api',
  pactFileDirectory: path.resolve(process.cwd(), 'pacts'),
  logDir: path.resolve(process.cwd(), 'logs'),
  logLevel: 'info',
  spec: 2,
  cors: true,
  port: 8080,
  host: 'localhost'
};
```

### Consumer Test Example
```javascript
// consumer.test.js
const { Pact } = require('@pact-foundation/pact');
const { getSignals } = require('./api-client');

describe('Nexus API Consumer Tests', () => {
  const provider = new Pact({
    consumer: 'nexus-frontend',
    provider: 'nexus-mcp-api',
  });

  beforeAll(() => provider.setup());
  afterEach(() => provider.verify());
  afterAll(() => provider.finalize());

  describe('GET /signals', () => {
    test('returns a list of signals', async () => {
      // Arrange
      const expectedSignal = {
        id: '507f1f77bcf86cd799439011',
        trialId: 'NCT12345678',
        severity: 'high',
        category: 'safety',
        description: 'Elevated liver enzymes',
        detectedAt: '2024-06-08T10:00:00Z'
      };

      await provider.addInteraction({
        state: 'signals exist for trial',
        uponReceiving: 'a request for signals',
        withRequest: {
          method: 'GET',
          path: '/api/v1/signals',
          query: {
            trialId: 'NCT12345678'
          },
          headers: {
            'Authorization': 'Bearer valid-token'
          }
        },
        willRespondWith: {
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: {
            data: [expectedSignal],
            pagination: {
              cursor: 'eyJpZCI6IjUwN2YxZjc3YmNmODZjZDc5OTQzOTAxMSJ9',
              hasMore: false
            }
          }
        }
      });

      // Act
      const signals = await getSignals({ trialId: 'NCT12345678' });

      // Assert
      expect(signals.data).toHaveLength(1);
      expect(signals.data[0]).toMatchObject(expectedSignal);
    });
  });
});
```

### Provider Verification
```javascript
// provider.test.js
const { Verifier } = require('@pact-foundation/pact');
const app = require('./app');
const { setupTestDatabase } = require('./test-utils');

describe('Pact Provider Verification', () => {
  let server;

  beforeAll(async () => {
    await setupTestDatabase();
    server = app.listen(8080);
  });

  afterAll(async () => {
    await server.close();
  });

  test('validates the expectations of nexus-frontend', () => {
    const opts = {
      provider: 'nexus-mcp-api',
      providerBaseUrl: 'http://localhost:8080',
      pactUrls: ['./pacts/nexus-frontend-nexus-mcp-api.json'],
      stateHandlers: {
        'signals exist for trial': async () => {
          await insertTestSignal({
            _id: '507f1f77bcf86cd799439011',
            trialId: 'NCT12345678',
            severity: 'high',
            category: 'safety',
            description: 'Elevated liver enzymes',
            detectedAt: new Date('2024-06-08T10:00:00Z')
          });
        }
      },
      requestFilter: (req, res, next) => {
        req.headers.authorization = 'Bearer valid-token';
        next();
      }
    };

    return new Verifier(opts).verifyProvider();
  });
});
```

## Integration Test Patterns

### Database Integration Tests
```javascript
// signals.integration.test.js
const request = require('supertest');
const app = require('../app');
const { MongoClient } = require('mongodb');
const { MongoMemoryServer } = require('mongodb-memory-server');

describe('Signals API Integration Tests', () => {
  let mongoServer;
  let mongoClient;
  let db;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const uri = mongoServer.getUri();
    mongoClient = new MongoClient(uri);
    await mongoClient.connect();
    db = mongoClient.db('test');
    app.locals.db = db;
  });

  afterAll(async () => {
    await mongoClient.close();
    await mongoServer.stop();
  });

  beforeEach(async () => {
    await db.collection('signals').deleteMany({});
  });

  describe('POST /api/v1/signals', () => {
    test('creates a new signal with proper validation', async () => {
      const newSignal = {
        trialId: 'NCT12345678',
        severity: 'high',
        category: 'safety',
        description: 'Abnormal lab values detected'
      };

      const response = await request(app)
        .post('/api/v1/signals')
        .set('Authorization', 'Bearer test-token')
        .send(newSignal)
        .expect(201);

      expect(response.body.data).toMatchObject({
        ...newSignal,
        id: expect.any(String),
        detectedAt: expect.any(String),
        status: 'open'
      });

      // Verify in database
      const saved = await db.collection('signals').findOne({
        _id: response.body.data.id
      });
      expect(saved).toBeTruthy();
    });

    test('validates required fields', async () => {
      const invalidSignal = {
        severity: 'high'
        // missing required fields
      };

      const response = await request(app)
        .post('/api/v1/signals')
        .set('Authorization', 'Bearer test-token')
        .send(invalidSignal)
        .expect(400);

      expect(response.body.error.code).toBe('VALIDATION_ERROR');
      expect(response.body.error.details.violations).toContainEqual(
        expect.objectContaining({
          field: 'trialId',
          code: 'REQUIRED'
        })
      );
    });
  });

  describe('GET /api/v1/signals with filters', () => {
    beforeEach(async () => {
      const signals = [
        {
          _id: '1',
          trialId: 'NCT12345678',
          severity: 'high',
          category: 'safety',
          detectedAt: new Date('2024-06-01')
        },
        {
          _id: '2',
          trialId: 'NCT12345678',
          severity: 'low',
          category: 'quality',
          detectedAt: new Date('2024-06-02')
        },
        {
          _id: '3',
          trialId: 'NCT87654321',
          severity: 'high',
          category: 'safety',
          detectedAt: new Date('2024-06-03')
        }
      ];
      await db.collection('signals').insertMany(signals);
    });

    test('filters by trial and severity', async () => {
      const response = await request(app)
        .get('/api/v1/signals')
        .query({
          trialId: 'NCT12345678',
          severity: 'high'
        })
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].id).toBe('1');
    });

    test('supports date range filtering', async () => {
      const response = await request(app)
        .get('/api/v1/signals')
        .query({
          dateFrom: '2024-06-02',
          dateTo: '2024-06-03'
        })
        .set('Authorization', 'Bearer test-token')
        .expect(200);

      expect(response.body.data).toHaveLength(2);
      expect(response.body.data.map(s => s.id)).toEqual(['3', '2']);
    });
  });
});
```

### Authentication Integration Tests
```javascript
// auth.integration.test.js
describe('Authentication Integration', () => {
  test('rejects requests without authentication', async () => {
    await request(app)
      .get('/api/v1/signals')
      .expect(401)
      .expect(res => {
        expect(res.body.error.code).toBe('AUTH_MISSING');
      });
  });

  test('validates JWT token format and signature', async () => {
    const invalidToken = 'invalid.jwt.token';
    
    await request(app)
      .get('/api/v1/signals')
      .set('Authorization', `Bearer ${invalidToken}`)
      .expect(401)
      .expect(res => {
        expect(res.body.error.code).toBe('AUTH_INVALID');
      });
  });

  test('enforces permission boundaries', async () => {
    const limitedToken = generateToken({
      permissions: ['read:signals']
    });

    await request(app)
      .post('/api/v1/signals')
      .set('Authorization', `Bearer ${limitedToken}`)
      .send({ /* signal data */ })
      .expect(403)
      .expect(res => {
        expect(res.body.error.code).toBe('PERMISSION_DENIED');
        expect(res.body.error.details.required).toBe('write:signals');
      });
  });
});
```

## Load Testing with k6

### Basic Load Test
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Ramp up to 10 users
    { duration: '1m', target: 50 },    // Stay at 50 users
    { duration: '2m', target: 100 },   // Ramp up to 100 users
    { duration: '1m', target: 100 },   // Stay at 100 users
    { duration: '30s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    errors: ['rate<0.1'],             // Error rate under 10%
  },
};

const BASE_URL = 'https://api.nexus-cmp.com/v1';
const AUTH_TOKEN = __ENV.AUTH_TOKEN;

export default function () {
  const params = {
    headers: {
      'Authorization': `Bearer ${AUTH_TOKEN}`,
      'Content-Type': 'application/json',
    },
  };

  // Test 1: List signals
  const listResponse = http.get(
    `${BASE_URL}/signals?trialId=NCT12345678`,
    params
  );
  
  const success = check(listResponse, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'has signals data': (r) => JSON.parse(r.body).data !== undefined,
  });

  errorRate.add(!success);

  sleep(1);

  // Test 2: Get specific signal
  if (success && listResponse.json('data').length > 0) {
    const signalId = listResponse.json('data')[0].id;
    const getResponse = http.get(
      `${BASE_URL}/signals/${signalId}`,
      params
    );

    check(getResponse, {
      'signal details status 200': (r) => r.status === 200,
      'signal has required fields': (r) => {
        const signal = JSON.parse(r.body).data;
        return signal.id && signal.trialId && signal.severity;
      },
    });
  }

  sleep(Math.random() * 3 + 1); // Random sleep 1-4 seconds
}
```

### Stress Test for MongoDB Queries
```javascript
// mongodb-stress-test.js
import http from 'k6/http';
import { check } from 'k6';
import { Trend } from 'k6/metrics';

const queryDuration = new Trend('query_duration');
const aggregationDuration = new Trend('aggregation_duration');

export const options = {
  scenarios: {
    simple_queries: {
      executor: 'constant-vus',
      vus: 50,
      duration: '5m',
      exec: 'simpleQueries',
    },
    complex_aggregations: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 20 },
        { duration: '3m', target: 20 },
        { duration: '2m', target: 0 },
      ],
      exec: 'complexAggregations',
    },
  },
};

export function simpleQueries() {
  const queries = [
    { collection: 'signals', filter: { severity: 'high' } },
    { collection: 'trials', filter: { status: 'active' } },
    { collection: 'datasets', filter: { trialId: 'NCT12345678' } },
  ];

  const query = queries[Math.floor(Math.random() * queries.length)];
  
  const response = http.post(
    `${BASE_URL}/mongodb/query`,
    JSON.stringify(query),
    { headers: { 'Content-Type': 'application/json' } }
  );

  queryDuration.add(response.timings.duration);

  check(response, {
    'query success': (r) => r.status === 200,
    'query fast': (r) => r.timings.duration < 200,
  });
}

export function complexAggregations() {
  const pipeline = [
    { $match: { detectedAt: { $gte: '2024-01-01' } } },
    { $group: { _id: '$severity', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
  ];

  const response = http.post(
    `${BASE_URL}/mongodb/aggregate`,
    JSON.stringify({
      collection: 'signals',
      pipeline: pipeline,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  aggregationDuration.add(response.timings.duration);

  check(response, {
    'aggregation success': (r) => r.status === 200,
    'aggregation reasonable time': (r) => r.timings.duration < 1000,
  });
}
```

### WebSocket Load Test
```javascript
// websocket-test.js
import ws from 'k6/ws';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 100 },  // 100 concurrent websocket connections
    { duration: '3m', target: 100 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  const url = 'wss://mcp.nexus-cmp.com/changes';
  
  ws.connect(url, null, function (socket) {
    socket.on('open', () => {
      socket.send(JSON.stringify({
        action: 'subscribe',
        streams: [{
          collection: 'signals',
          pipeline: [{ $match: { severity: 'high' } }]
        }]
      }));
    });

    socket.on('message', (data) => {
      const message = JSON.parse(data);
      check(message, {
        'received change event': () => message.event !== undefined,
      });
    });

    socket.setTimeout(() => {
      socket.close();
    }, 30000); // Keep connection for 30 seconds
  });
}
```

## API Mocking for Development

### Mock Server Setup
```javascript
// mock-server.js
const express = require('express');
const { faker } = require('@faker-js/faker');

const app = express();
app.use(express.json());

// Mock data generators
function generateSignal(overrides = {}) {
  return {
    id: faker.datatype.uuid(),
    trialId: `NCT${faker.datatype.number({ min: 10000000, max: 99999999 })}`,
    severity: faker.helpers.arrayElement(['low', 'medium', 'high', 'critical']),
    category: faker.helpers.arrayElement(['safety', 'efficacy', 'quality', 'operational']),
    description: faker.lorem.sentence(),
    detectedAt: faker.date.recent(),
    status: faker.helpers.arrayElement(['open', 'investigating', 'closed']),
    ...overrides
  };
}

// Mock endpoints
app.get('/api/v1/signals', (req, res) => {
  const { limit = 20, severity, trialId } = req.query;
  
  let signals = Array.from({ length: 100 }, () => generateSignal());
  
  if (severity) {
    signals = signals.filter(s => s.severity === severity);
  }
  if (trialId) {
    signals = signals.filter(s => s.trialId === trialId);
  }
  
  res.json({
    data: signals.slice(0, parseInt(limit)),
    pagination: {
      cursor: faker.datatype.uuid(),
      hasMore: signals.length > limit
    }
  });
});

app.post('/api/v1/signals', (req, res) => {
  const newSignal = generateSignal({
    ...req.body,
    id: faker.datatype.uuid(),
    detectedAt: new Date(),
    status: 'open'
  });
  
  res.status(201).json({ data: newSignal });
});

// Error simulation
app.get('/api/v1/error/:code', (req, res) => {
  const errorCode = parseInt(req.params.code);
  
  const errors = {
    400: { code: 'VALIDATION_ERROR', message: 'Invalid request' },
    401: { code: 'AUTH_INVALID', message: 'Invalid authentication' },
    403: { code: 'PERMISSION_DENIED', message: 'Insufficient permissions' },
    404: { code: 'RESOURCE_NOT_FOUND', message: 'Resource not found' },
    500: { code: 'INTERNAL_ERROR', message: 'Internal server error' }
  };
  
  res.status(errorCode).json({ error: errors[errorCode] });
});

// Delay simulation
app.use((req, res, next) => {
  const delay = req.query._delay || 0;
  setTimeout(next, delay);
});

module.exports = app;
```

### Mock Data Fixtures
```javascript
// fixtures/signals.js
module.exports = {
  highSeveritySignal: {
    id: 'sig_001',
    trialId: 'NCT12345678',
    severity: 'high',
    category: 'safety',
    description: 'Elevated liver enzymes in 15% of treatment group',
    detectedAt: '2024-06-01T10:00:00Z',
    status: 'open',
    metadata: {
      affectedPatients: 23,
      pValue: 0.003,
      baselineRate: 0.05,
      observedRate: 0.15
    }
  },
  
  criticalSignal: {
    id: 'sig_002',
    trialId: 'NCT12345678',
    severity: 'critical',
    category: 'safety',
    description: 'Serious adverse event cluster detected',
    detectedAt: '2024-06-05T14:30:00Z',
    status: 'investigating',
    assignedTo: 'medical_monitor_01',
    metadata: {
      eventType: 'cardiac',
      eventCount: 5,
      timeWindow: '7d'
    }
  }
};
```

## Postman Collection Management

### Collection Structure
```json
{
  "info": {
    "name": "Nexus MCP API",
    "description": "API collection for Nexus clinical trial platform",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{auth_token}}",
        "type": "string"
      }
    ]
  },
  "variable": [
    {
      "key": "base_url",
      "value": "https://api.nexus-cmp.com/v1",
      "type": "string"
    },
    {
      "key": "auth_token",
      "value": "",
      "type": "string"
    }
  ],
  "item": [
    {
      "name": "Authentication",
      "item": [
        {
          "name": "Login",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test('Status code is 200', () => {",
                  "    pm.response.to.have.status(200);",
                  "});",
                  "",
                  "const response = pm.response.json();",
                  "pm.collectionVariables.set('auth_token', response.token);",
                  "",
                  "pm.test('Token is returned', () => {",
                  "    pm.expect(response).to.have.property('token');",
                  "});"
                ]
              }
            }
          ],
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n    \"username\": \"{{username}}\",\n    \"password\": \"{{password}}\"\n}"
            },
            "url": {
              "raw": "{{base_url}}/auth/login",
              "host": ["{{base_url}}"],
              "path": ["auth", "login"]
            }
          }
        }
      ]
    },
    {
      "name": "Signals",
      "item": [
        {
          "name": "List Signals",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test('Response time is less than 500ms', () => {",
                  "    pm.expect(pm.response.responseTime).to.be.below(500);",
                  "});",
                  "",
                  "pm.test('Response has signals array', () => {",
                  "    const response = pm.response.json();",
                  "    pm.expect(response).to.have.property('data');",
                  "    pm.expect(response.data).to.be.an('array');",
                  "});"
                ]
              }
            }
          ],
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "{{base_url}}/signals?trialId=NCT12345678&severity=high",
              "host": ["{{base_url}}"],
              "path": ["signals"],
              "query": [
                { "key": "trialId", "value": "NCT12345678" },
                { "key": "severity", "value": "high" }
              ]
            }
          }
        }
      ]
    }
  ]
}
```

### Environment Configuration
```json
{
  "id": "env_001",
  "name": "Production",
  "values": [
    {
      "key": "base_url",
      "value": "https://api.nexus-cmp.com/v1",
      "enabled": true
    },
    {
      "key": "username",
      "value": "test@example.com",
      "enabled": true
    },
    {
      "key": "password",
      "value": "",
      "enabled": true,
      "type": "secret"
    }
  ]
}
```

## Automated API Test Generation

### OpenAPI to Test Generation
```javascript
// generate-tests.js
const SwaggerParser = require('@apidevtools/swagger-parser');
const fs = require('fs').promises;

async function generateTests(specPath) {
  const api = await SwaggerParser.validate(specPath);
  const tests = [];

  for (const [path, methods] of Object.entries(api.paths)) {
    for (const [method, operation] of Object.entries(methods)) {
      if (['get', 'post', 'put', 'patch', 'delete'].includes(method)) {
        tests.push(generateTest(path, method, operation));
      }
    }
  }

  return tests.join('\n\n');
}

function generateTest(path, method, operation) {
  const testName = operation.operationId || `${method} ${path}`;
  const responses = Object.keys(operation.responses);
  
  return `
describe('${testName}', () => {
  ${responses.map(status => `
  test('handles ${status} response', async () => {
    const response = await request(app)
      .${method}('${path}')
      .set('Authorization', 'Bearer test-token')
      ${method !== 'get' ? `.send(${generateRequestBody(operation)})` : ''}
      .expect(${status});
      
    ${generateAssertions(status, operation.responses[status])}
  });
  `).join('\n')}
});`;
}
```

### Property-Based Testing
```javascript
// property-tests.js
const fc = require('fast-check');
const { validateSignal } = require('./validators');

describe('Signal Validation Property Tests', () => {
  test('valid signals always pass validation', () => {
    fc.assert(
      fc.property(
        fc.record({
          trialId: fc.stringMatching(/^NCT[0-9]{8}$/),
          severity: fc.constantFrom('low', 'medium', 'high', 'critical'),
          category: fc.constantFrom('safety', 'efficacy', 'quality', 'operational'),
          description: fc.string({ minLength: 1, maxLength: 5000 })
        }),
        (signal) => {
          const result = validateSignal(signal);
          expect(result.valid).toBe(true);
        }
      )
    );
  });

  test('invalid trial IDs always fail validation', () => {
    fc.assert(
      fc.property(
        fc.string().filter(s => !s.match(/^NCT[0-9]{8}$/)),
        (invalidTrialId) => {
          const signal = {
            trialId: invalidTrialId,
            severity: 'high',
            category: 'safety',
            description: 'Test'
          };
          const result = validateSignal(signal);
          expect(result.valid).toBe(false);
          expect(result.errors).toContainEqual(
            expect.objectContaining({ field: 'trialId' })
          );
        }
      )
    );
  });
});
```

## Performance Benchmarking

### Benchmark Suite
```javascript
// benchmark.js
const Benchmark = require('benchmark');
const suite = new Benchmark.Suite();

// Add tests
suite
  .add('Simple Query', {
    defer: true,
    fn: async function(deferred) {
      await fetch(`${BASE_URL}/signals?limit=10`);
      deferred.resolve();
    }
  })
  .add('Complex Aggregation', {
    defer: true,
    fn: async function(deferred) {
      await fetch(`${BASE_URL}/mongodb/aggregate`, {
        method: 'POST',
        body: JSON.stringify({
          collection: 'signals',
          pipeline: [
            { $match: { severity: 'high' } },
            { $group: { _id: '$category', count: { $sum: 1 } } }
          ]
        })
      });
      deferred.resolve();
    }
  })
  .add('Bulk Insert', {
    defer: true,
    fn: async function(deferred) {
      const signals = Array.from({ length: 100 }, () => ({
        trialId: 'NCT12345678',
        severity: 'medium',
        category: 'quality'
      }));
      
      await fetch(`${BASE_URL}/signals/bulk`, {
        method: 'POST',
        body: JSON.stringify({ signals })
      });
      deferred.resolve();
    }
  })
  // Add listeners
  .on('cycle', function(event) {
    console.log(String(event.target));
  })
  .on('complete', function() {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  // Run async
  .run({ 'async': true });
```

### Performance Metrics Collection
```javascript
// metrics.js
class PerformanceMetrics {
  constructor() {
    this.metrics = {
      requests: new Map(),
      errors: new Map(),
      durations: []
    };
  }

  recordRequest(endpoint, method, duration, status) {
    const key = `${method} ${endpoint}`;
    
    if (!this.metrics.requests.has(key)) {
      this.metrics.requests.set(key, {
        count: 0,
        totalDuration: 0,
        minDuration: Infinity,
        maxDuration: 0,
        statusCodes: new Map()
      });
    }
    
    const metric = this.metrics.requests.get(key);
    metric.count++;
    metric.totalDuration += duration;
    metric.minDuration = Math.min(metric.minDuration, duration);
    metric.maxDuration = Math.max(metric.maxDuration, duration);
    
    metric.statusCodes.set(
      status,
      (metric.statusCodes.get(status) || 0) + 1
    );
    
    this.metrics.durations.push(duration);
  }

  getReport() {
    const report = {
      summary: {
        totalRequests: Array.from(this.metrics.requests.values())
          .reduce((sum, m) => sum + m.count, 0),
        avgDuration: this.calculatePercentile(50),
        p95Duration: this.calculatePercentile(95),
        p99Duration: this.calculatePercentile(99)
      },
      endpoints: {}
    };
    
    for (const [endpoint, metrics] of this.metrics.requests.entries()) {
      report.endpoints[endpoint] = {
        requests: metrics.count,
        avgDuration: metrics.totalDuration / metrics.count,
        minDuration: metrics.minDuration,
        maxDuration: metrics.maxDuration,
        statusCodes: Object.fromEntries(metrics.statusCodes)
      };
    }
    
    return report;
  }

  calculatePercentile(percentile) {
    const sorted = this.metrics.durations.sort((a, b) => a - b);
    const index = Math.ceil((percentile / 100) * sorted.length) - 1;
    return sorted[index];
  }
}
```

## Best Practices

### Test Organization
1. **Group by Feature**: Organize tests by business domain
2. **Use Descriptive Names**: Test names should explain what they verify
3. **Follow AAA Pattern**: Arrange, Act, Assert
4. **One Assertion Per Test**: Keep tests focused
5. **Mock External Dependencies**: Isolate the system under test

### Test Data Management
1. **Use Factories**: Create reusable test data generators
2. **Seed Databases**: Consistent starting state for tests
3. **Clean Up After Tests**: Prevent test pollution
4. **Use Realistic Data**: Test with production-like data
5. **Version Test Data**: Track changes to test fixtures

### Performance Testing
1. **Establish Baselines**: Know your normal performance
2. **Test Under Load**: Simulate realistic concurrent users
3. **Monitor Resources**: Track CPU, memory, connections
4. **Test Failure Scenarios**: How does the system degrade?
5. **Automate Performance Tests**: Run regularly to catch regressions

### Security Testing
1. **Test Authentication**: Verify all auth mechanisms
2. **Test Authorization**: Check permission boundaries
3. **Test Input Validation**: Try to break validators
4. **Test Rate Limiting**: Ensure limits work correctly
5. **Run Security Scans**: Use tools like OWASP ZAP

### Continuous Integration
1. **Run Tests on Every Commit**: Catch issues early
2. **Parallelize Test Execution**: Reduce feedback time
3. **Report Test Coverage**: Track untested code
4. **Fail Fast**: Stop on first failure in CI
5. **Archive Test Results**: Track trends over time