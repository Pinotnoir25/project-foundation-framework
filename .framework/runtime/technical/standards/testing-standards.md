# Testing Standards

This document outlines the testing standards and best practices for the Nexus MCP MongoDB integration project.

## Table of Contents

1. [Test-Driven Development (TDD) Approach](#test-driven-development-tdd-approach)
2. [Test File Naming and Organization](#test-file-naming-and-organization)
3. [Test Coverage Requirements](#test-coverage-requirements)
4. [Mock Data Management](#mock-data-management)
5. [Test Database Strategies](#test-database-strategies)
6. [CI/CD Integration](#cicd-integration)

## Test-Driven Development (TDD) Approach

### TDD Cycle

Follow the Red-Green-Refactor cycle:

1. **Red**: Write a failing test
2. **Green**: Write minimal code to pass the test
3. **Refactor**: Improve code while keeping tests green

### TDD Example - Signal Detection Service

```typescript
// Step 1: Write failing test
// signal-detection.service.test.ts
describe('SignalDetectionService', () => {
  describe('detectAnomalies', () => {
    it('should detect z-score anomalies above threshold', async () => {
      // Arrange
      const service = new SignalDetectionService();
      const data = [1, 2, 2, 2, 2, 2, 2, 2, 2, 100]; // 100 is an outlier
      const threshold = 2.5; // z-score threshold
      
      // Act
      const anomalies = await service.detectAnomalies(data, threshold);
      
      // Assert
      expect(anomalies).toHaveLength(1);
      expect(anomalies[0]).toEqual({
        value: 100,
        index: 9,
        zScore: expect.any(Number),
        isAnomaly: true
      });
      expect(anomalies[0].zScore).toBeGreaterThan(threshold);
    });
  });
});

// Step 2: Write minimal code to pass
// signal-detection.service.ts
export class SignalDetectionService {
  async detectAnomalies(data: number[], threshold: number): Promise<Anomaly[]> {
    const mean = data.reduce((sum, val) => sum + val, 0) / data.length;
    const variance = data.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / data.length;
    const stdDev = Math.sqrt(variance);
    
    return data
      .map((value, index) => {
        const zScore = Math.abs((value - mean) / stdDev);
        return {
          value,
          index,
          zScore,
          isAnomaly: zScore > threshold
        };
      })
      .filter(item => item.isAnomaly);
  }
}

// Step 3: Refactor for better design
export class SignalDetectionService {
  async detectAnomalies(
    data: number[], 
    threshold: number, 
    method: DetectionMethod = 'z-score'
  ): Promise<Anomaly[]> {
    const detector = this.getDetector(method);
    return detector.detect(data, threshold);
  }
  
  private getDetector(method: DetectionMethod): AnomalyDetector {
    switch (method) {
      case 'z-score':
        return new ZScoreDetector();
      case 'iqr':
        return new IQRDetector();
      default:
        throw new Error(`Unknown detection method: ${method}`);
    }
  }
}
```

### TDD Best Practices

1. **Write the test first, always**
2. **One assertion per test when possible**
3. **Test behavior, not implementation**
4. **Keep tests independent**
5. **Use descriptive test names**

```typescript
// Good test names
it('should return empty array when no anomalies detected')
it('should throw ValidationError when threshold is negative')
it('should calculate z-score using population standard deviation')

// Bad test names
it('should work')
it('test anomaly detection')
it('detectAnomalies function')
```

## Test File Naming and Organization

### File Structure

```bash
/src
  /services
    signal-detection.service.ts
    signal-detection.service.test.ts    # Unit tests
    signal-detection.service.spec.ts    # Alternative naming
  /integration
    /tests
      mongodb-connection.test.ts        # Integration tests
  /e2e
    /tests
      signal-api.e2e.test.ts           # End-to-end tests
/tests
  /fixtures                             # Test data
    users.json
    trials.json
  /helpers                              # Test utilities
    test-db.ts
    test-server.ts
  /mocks                               # Mock implementations
    mongodb.mock.ts
```

### Test Categories

```typescript
// Unit Test - No external dependencies
// user.service.test.ts
describe('UserService (Unit)', () => {
  let service: UserService;
  let mockRepository: jest.Mocked<UserRepository>;
  
  beforeEach(() => {
    mockRepository = createMockRepository();
    service = new UserService(mockRepository);
  });
  
  it('should hash password before saving user', async () => {
    const user = { email: 'test@example.com', password: 'plain' };
    await service.createUser(user);
    
    expect(mockRepository.save).toHaveBeenCalledWith(
      expect.objectContaining({
        email: user.email,
        password: expect.not.stringMatching('plain')
      })
    );
  });
});

// Integration Test - With real dependencies
// mongodb-connection.test.ts
describe('MongoDB Connection (Integration)', () => {
  let connection: MongoClient;
  
  beforeAll(async () => {
    connection = await connectToTestDatabase();
  });
  
  afterAll(async () => {
    await connection.close();
  });
  
  it('should connect through SSH tunnel', async () => {
    const db = connection.db('test');
    const collections = await db.listCollections().toArray();
    expect(collections).toBeDefined();
  });
});

// E2E Test - Full application flow
// signal-api.e2e.test.ts
describe('Signal Detection API (E2E)', () => {
  let app: Application;
  
  beforeAll(async () => {
    app = await createTestApp();
  });
  
  it('should detect and return signals via API', async () => {
    const response = await request(app)
      .post('/api/signals/detect')
      .send({ trialId: 'TEST-001', threshold: 0.95 })
      .expect(200);
      
    expect(response.body).toMatchObject({
      success: true,
      signals: expect.arrayContaining([
        expect.objectContaining({
          type: 'statistical_anomaly',
          severity: expect.any(String)
        })
      ])
    });
  });
});
```

## Test Coverage Requirements

### Coverage Targets

```json
// jest.config.js or vitest.config.js
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    },
    "src/services/": {
      "branches": 90,
      "functions": 90,
      "lines": 90,
      "statements": 90
    },
    "src/utils/": {
      "branches": 100,
      "functions": 100,
      "lines": 100,
      "statements": 100
    }
  }
}
```

### Coverage Report Configuration

```javascript
// jest.config.js
module.exports = {
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{js,ts}',
    '!src/**/*.spec.{js,ts}',
    '!src/test/**/*',
  ],
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/coverage/',
    '/__tests__/',
  ],
};
```

### Enforcing Coverage in CI/CD

```yaml
# .github/workflows/test.yml
name: Test and Coverage
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests with coverage
        run: npm run test:coverage
        
      - name: Check coverage thresholds
        run: npm run test:coverage:check
        
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          fail_ci_if_error: true
          
      - name: Comment PR with coverage
        uses: 5monkeys/cobertura-action@master
        with:
          path: coverage/cobertura-coverage.xml
          minimum_coverage: 80
```

## Mock Data Management

### Centralized Mock Data

```typescript
// tests/fixtures/users.ts
export const mockUsers = {
  admin: {
    id: 'user-001',
    email: 'admin@example.com',
    role: 'admin',
    organization: 'nexus-pharma',
    permissions: ['read', 'write', 'delete', 'admin']
  },
  researcher: {
    id: 'user-002',
    email: 'researcher@example.com',
    role: 'researcher',
    organization: 'clinical-research-org',
    permissions: ['read', 'write']
  },
  viewer: {
    id: 'user-003',
    email: 'viewer@example.com',
    role: 'viewer',
    organization: 'monitor-org',
    permissions: ['read']
  }
};

// tests/fixtures/clinical-trials.ts
export const mockTrials = {
  active: {
    id: 'TRIAL-001',
    name: 'Diabetes Study Phase 3',
    status: 'active',
    sites: [
      { id: 'SITE-001', name: 'Boston General', patientCount: 150 },
      { id: 'SITE-002', name: 'NYC Medical', patientCount: 200 }
    ],
    startDate: new Date('2024-01-01'),
    variables: ['glucose_level', 'blood_pressure', 'weight']
  },
  completed: {
    id: 'TRIAL-002',
    name: 'Cardio Study Phase 2',
    status: 'completed',
    // ... more data
  }
};
```

### Mock Factories

```typescript
// tests/factories/signal.factory.ts
import { Factory } from 'fishery';
import { Signal } from '@/types';

export const signalFactory = Factory.define<Signal>(({ sequence }) => ({
  id: `SIGNAL-${sequence}`,
  type: 'statistical_anomaly',
  severity: 'medium',
  description: 'Anomaly detected in patient data',
  trialId: 'TRIAL-001',
  siteId: 'SITE-001',
  variable: 'glucose_level',
  detectedAt: new Date(),
  score: 0.96,
  status: 'open',
  metadata: {
    algorithm: 'z-score',
    threshold: 0.95,
    sampleSize: 100
  }
}));

// Usage in tests
const signal = signalFactory.build();
const highSeveritySignal = signalFactory.build({ severity: 'high' });
const signals = signalFactory.buildList(5);
```

### Mock Service Pattern

```typescript
// tests/mocks/mongodb.mock.ts
export class MockMongoClient {
  private data: Map<string, any[]> = new Map();
  
  constructor(initialData?: Record<string, any[]>) {
    if (initialData) {
      Object.entries(initialData).forEach(([collection, docs]) => {
        this.data.set(collection, docs);
      });
    }
  }
  
  db(name: string) {
    return {
      collection: (collectionName: string) => ({
        find: (query: any) => ({
          toArray: async () => {
            const docs = this.data.get(collectionName) || [];
            return this.filterByQuery(docs, query);
          }
        }),
        findOne: async (query: any) => {
          const docs = this.data.get(collectionName) || [];
          return this.filterByQuery(docs, query)[0] || null;
        },
        insertOne: async (doc: any) => {
          const docs = this.data.get(collectionName) || [];
          const newDoc = { ...doc, _id: `mock-${Date.now()}` };
          docs.push(newDoc);
          this.data.set(collectionName, docs);
          return { insertedId: newDoc._id };
        }
      })
    };
  }
  
  private filterByQuery(docs: any[], query: any): any[] {
    // Simple query matching for tests
    return docs.filter(doc => {
      return Object.entries(query).every(([key, value]) => {
        return doc[key] === value;
      });
    });
  }
}
```

## Test Database Strategies

### In-Memory MongoDB

```typescript
// tests/helpers/test-db.ts
import { MongoMemoryServer } from 'mongodb-memory-server';
import { MongoClient } from 'mongodb';

let mongoServer: MongoMemoryServer;
let client: MongoClient;

export async function setupTestDatabase(): Promise<MongoClient> {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  
  client = new MongoClient(uri);
  await client.connect();
  
  // Seed initial data
  await seedTestData(client);
  
  return client;
}

export async function teardownTestDatabase(): Promise<void> {
  if (client) {
    await client.close();
  }
  if (mongoServer) {
    await mongoServer.stop();
  }
}

async function seedTestData(client: MongoClient): Promise<void> {
  const db = client.db('test');
  
  // Create collections with indexes
  await db.createCollection('users');
  await db.collection('users').createIndex({ email: 1 }, { unique: true });
  
  // Insert test data
  await db.collection('users').insertMany([
    mockUsers.admin,
    mockUsers.researcher,
    mockUsers.viewer
  ]);
}

// Usage in tests
describe('User Repository', () => {
  let db: MongoClient;
  
  beforeAll(async () => {
    db = await setupTestDatabase();
  });
  
  afterAll(async () => {
    await teardownTestDatabase();
  });
  
  beforeEach(async () => {
    // Clear specific collections between tests
    await db.db('test').collection('sessions').deleteMany({});
  });
});
```

### Test Containers for Integration Tests

```typescript
// tests/helpers/test-containers.ts
import { GenericContainer, StartedTestContainer } from 'testcontainers';

export class MongoDBContainer {
  private container: StartedTestContainer;
  
  async start(): Promise<string> {
    this.container = await new GenericContainer('mongo:7.0.5')
      .withExposedPorts(27017)
      .withEnvironment({
        MONGO_INITDB_ROOT_USERNAME: 'test',
        MONGO_INITDB_ROOT_PASSWORD: 'test',
        MONGO_INITDB_DATABASE: 'test'
      })
      .start();
      
    const host = this.container.getHost();
    const port = this.container.getMappedPort(27017);
    
    return `mongodb://test:test@${host}:${port}/test?authSource=admin`;
  }
  
  async stop(): Promise<void> {
    if (this.container) {
      await this.container.stop();
    }
  }
}

// Usage for integration tests
describe('MongoDB Integration', () => {
  const mongoContainer = new MongoDBContainer();
  let connectionString: string;
  
  beforeAll(async () => {
    connectionString = await mongoContainer.start();
  }, 30000); // Increased timeout for container startup
  
  afterAll(async () => {
    await mongoContainer.stop();
  });
});
```

### Database Transaction Testing

```typescript
// tests/helpers/transaction-test.ts
export async function withTransaction<T>(
  client: MongoClient,
  callback: (session: ClientSession) => Promise<T>
): Promise<T> {
  const session = client.startSession();
  
  try {
    return await session.withTransaction(callback);
  } finally {
    await session.endSession();
  }
}

// Test with transactions
describe('Signal Service - Transactions', () => {
  it('should rollback on error', async () => {
    const signalsBefore = await db.collection('signals').countDocuments();
    
    try {
      await withTransaction(db, async (session) => {
        // Create signal
        await db.collection('signals').insertOne(
          { type: 'test' },
          { session }
        );
        
        // Force error
        throw new Error('Rollback test');
      });
    } catch (error) {
      // Expected error
    }
    
    const signalsAfter = await db.collection('signals').countDocuments();
    expect(signalsAfter).toBe(signalsBefore);
  });
});
```

## CI/CD Integration

### GitHub Actions Test Pipeline

```yaml
# .github/workflows/test-pipeline.yml
name: Test Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run linting
        run: npm run lint
        
      - name: Run unit tests
        run: npm run test:unit
        
      - name: Upload coverage
        uses: actions/upload-artifact@v3
        with:
          name: coverage-${{ matrix.node-version }}
          path: coverage/

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    
    services:
      mongodb:
        image: mongo:7.0.5
        ports:
          - 27017:27017
        env:
          MONGO_INITDB_ROOT_USERNAME: test
          MONGO_INITDB_ROOT_PASSWORD: test
        options: >-
          --health-cmd "mongosh --eval 'db.adminCommand({ping: 1})'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
          
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 20
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run integration tests
        run: npm run test:integration
        env:
          MONGO_URI: mongodb://test:test@localhost:27017/test?authSource=admin
          
      - name: Run E2E tests
        run: npm run test:e2e
        
  security-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run security audit
        run: npm audit --production
        
      - name: Run OWASP dependency check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'nexus-mcp'
          path: '.'
          format: 'HTML'
          
      - name: Upload security reports
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: reports/

  test-report:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests]
    if: always()
    
    steps:
      - name: Download coverage artifacts
        uses: actions/download-artifact@v3
        
      - name: Merge coverage reports
        run: |
          npm install -g nyc
          nyc merge coverage-* coverage/merged.json
          nyc report -r lcov -r text --report-dir coverage/final
          
      - name: Generate test report
        uses: dorny/test-reporter@v1
        with:
          name: Test Results
          path: 'test-results/**/*.xml'
          reporter: 'jest-junit'
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: run-tests
        name: Run tests
        entry: npm run test:unit -- --bail --findRelatedTests
        language: system
        pass_filenames: true
        types: [javascript, typescript]
        
      - id: check-coverage
        name: Check test coverage
        entry: npm run test:coverage:check
        language: system
        pass_filenames: false
        
      - id: lint
        name: Lint code
        entry: npm run lint
        language: system
        types: [javascript, typescript]
```

### Test Execution Scripts

```json
// package.json
{
  "scripts": {
    "test": "jest",
    "test:unit": "jest --testPathPattern='\\.test\\.ts$'",
    "test:integration": "jest --testPathPattern='\\.integration\\.test\\.ts$'",
    "test:e2e": "jest --testPathPattern='\\.e2e\\.test\\.ts$'",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:coverage:check": "jest --coverage --coverageThreshold='{\"global\":{\"branches\":80,\"functions\":80,\"lines\":80,\"statements\":80}}'",
    "test:ci": "jest --ci --coverage --maxWorkers=2",
    "test:debug": "node --inspect-brk ./node_modules/.bin/jest --runInBand"
  }
}
```