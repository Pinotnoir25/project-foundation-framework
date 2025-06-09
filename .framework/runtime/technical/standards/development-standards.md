# Development Standards

This document outlines the coding standards, workflows, and best practices for the {{PROJECT_NAME}} project.

## Table of Contents

1. [Code Style Guides](#code-style-guides)
2. [Git Workflow](#git-workflow)
3. [Code Review Standards](#code-review-standards)
4. [Documentation Requirements](#documentation-requirements)
5. [Naming Conventions](#naming-conventions)
6. [Error Handling Patterns](#error-handling-patterns)
7. [Logging Standards](#logging-standards)

## Code Style Guides

### TypeScript/JavaScript

We follow the [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) with TypeScript extensions.

#### Key Rules

1. **Use TypeScript strict mode**
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}
```

2. **Prefer const over let, never use var**
```typescript
// Good
const MAX_RETRY_COUNT = 3;
const userConfig = { name: 'John' };

// Bad
var count = 0;
let CONSTANT_VALUE = 42;
```

3. **Use arrow functions for callbacks**
```typescript
// Good
const processedData = data.map((item) => item.value * 2);

// Bad
const processedData = data.map(function(item) {
  return item.value * 2;
});
```

4. **Async/await over promises**
```typescript
// Good
async function fetchUserData(userId: string): Promise<User> {
  try {
    const response = await api.getUser(userId);
    return response.data;
  } catch (error) {
    logger.error('Failed to fetch user', { userId, error });
    throw new UserFetchError(userId, error);
  }
}

// Bad
function fetchUserData(userId: string): Promise<User> {
  return api.getUser(userId)
    .then(response => response.data)
    .catch(error => {
      logger.error('Failed to fetch user', { userId, error });
      throw new UserFetchError(userId, error);
    });
}
```

5. **Interface over type for object shapes**
```typescript
// Good
interface UserConfig {
  id: string;
  name: string;
  permissions: Permission[];
}

// Use type for unions, intersections, and mapped types
type Status = 'active' | 'inactive' | 'pending';
type ReadonlyUser = Readonly<User>;
```

### Python

We follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) with additional guidelines:

1. **Use type hints**
```python
from typing import List, Dict, Optional

def process_data(
    data_items: List[Dict[str, Any]], 
    threshold: float = 0.95
) -> Optional[ProcessedResult]:
    """Process {{domain}} data with {{analysis_type}} analysis."""
    pass
```

2. **Docstrings for all public functions**
```python
def calculate_score(
    dataset: pd.DataFrame,
    variable: str,
    method: str = "z-score"
) -> float:
    """
    Calculate score for a specific variable in the dataset.
    
    Args:
        dataset: {{Data type}} data as pandas DataFrame
        variable: Name of the variable to analyze
        method: Analysis method to use (default: "z-score")
        
    Returns:
        Score between 0 and 1
        
    Raises:
        ValueError: If variable not found in dataset
        CalculationError: If calculation fails
    """
    pass
```

## Git Workflow

### Branching Strategy

We use Git Flow with the following branches:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Emergency fixes to production
- `release/*` - Release preparation

### Branch Naming

```bash
# Features
feature/add-mongodb-connection-pooling
feature/implement-signal-detection-api

# Bugfixes
bugfix/fix-ssh-tunnel-timeout
bugfix/correct-user-permission-check

# Hotfixes
hotfix/patch-security-vulnerability
```

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```bash
# Format
<type>(<scope>): <subject>

<body>

<footer>

# Examples
feat(auth): add {{connection_type}} authentication for {{database}}

Implement secure {{connection_type}} connection with {{auth_method}} authentication
to access the {{database}} instance. This includes retry logic
and connection pooling.

Closes #123

fix(processing): correct calculation for {{metric}}

The {{metric}} calculation was using {{incorrect_method}} instead
of {{correct_method}}, leading to incorrect results.

BREAKING CHANGE: This changes the {{metric}} calculation results
```

#### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or modifying tests
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Maintenance tasks

### Pull Request Process

1. **Create PR from feature branch to develop**
2. **PR Title Format**: Same as commit message
3. **PR Description Template**:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings
```

## Code Review Standards

### Review Checklist

1. **Functionality**
   - Does the code do what it's supposed to do?
   - Are edge cases handled?
   - Is error handling appropriate?

2. **Code Quality**
   - Is the code readable and maintainable?
   - Are there any code smells?
   - Is the code DRY (Don't Repeat Yourself)?

3. **Performance**
   - Are there any obvious performance issues?
   - Is pagination implemented for large datasets?
   - Are database queries optimized?

4. **Security**
   - No hardcoded credentials
   - Input validation present
   - SQL injection prevention
   - Proper authentication/authorization

5. **Testing**
   - Are tests included?
   - Do tests cover edge cases?
   - Is test coverage adequate (>80%)?

### Review Comments

```typescript
// Use constructive comments
// Good: "Consider using a Map here for O(1) lookups instead of array.find()"
// Bad: "This is inefficient"

// Prefix comments with severity
// [MUST]: Security issue or bug that must be fixed
// [SHOULD]: Strong suggestion for improvement
// [CONSIDER]: Optional improvement
// [NIT]: Minor style issue
```

## Documentation Requirements

### Inline Comments

1. **Comment why, not what**
```typescript
// Good: Calculate {{metric}} to identify {{pattern}} in {{data_type}} data
const score = (value - mean) / stdDev;

// Bad: Subtract mean from value and divide by standard deviation
const score = (value - mean) / stdDev;
```

2. **Document complex business logic**
```typescript
/**
 * Apply {{platform}} rules for {{detection_type}} detection.
 * {{Detection_items}} are generated when:
 * 1. {{Metric}} score exceeds threshold ({{threshold}})
 * 2. Pattern persists for minimum duration ({{duration}})
 * 3. Impact affects minimum percentage of {{entities}} (>{{percentage}}%)
 */
function detectPatterns(data: DataSet): Result[] {
  // Implementation
}
```

### README Files

Each module should have a README with:

1. **Purpose and overview**
2. **Installation/setup instructions**
3. **Usage examples**
4. **API documentation**
5. **Configuration options**
6. **Troubleshooting guide**

### API Documentation

Use JSDoc for TypeScript/JavaScript:

```typescript
/**
 * Connect to {{database}} through {{connection_method}}
 * @param {ConnectionConfig} config - Database connection configuration
 * @param {string} config.host - Server hostname
 * @param {number} config.port - Server port
 * @param {string} config.connectionString - Database connection string
 * @returns {Promise<DatabaseClient>} Connected database client
 * @throws {ConnectionError} When connection fails
 * @throws {DatabaseError} When database connection fails
 * @example
 * const client = await connectToDatabase({
 *   host: 'server.example.com',
 *   port: {{default_port}},
 *   connectionString: '{{protocol}}://localhost:{{port}}/{{database_name}}'
 * });
 */
```

## Naming Conventions

### Files and Folders

```bash
# TypeScript/JavaScript files
user-service.ts          # Kebab case for files
UserService.ts          # Pascal case for class files
user.interface.ts       # Interface files
user.types.ts          # Type definition files
user.test.ts           # Test files
user.mock.ts           # Mock data files

# Folders
/src
  /services            # Plural for collections
  /models             
  /interfaces
  /utils
  /config
```

### Variables and Functions

```typescript
// Constants: UPPER_SNAKE_CASE
const MAX_RETRY_ATTEMPTS = 3;
const DEFAULT_TIMEOUT_MS = 5000;

// Variables: camelCase
const userName = 'John';
let retryCount = 0;

// Functions: camelCase, verb + noun
function calculateAnomalyScore(): number { }
function fetchUserPermissions(): Permission[] { }

// Classes: PascalCase
class SignalDetectionService { }
class MongoDBConnectionManager { }

// Interfaces: PascalCase with 'I' prefix for models
interface IUser {
  id: string;
  name: string;
}

// Types: PascalCase
type PermissionLevel = 'read' | 'write' | 'admin';
```

### Database Related

```typescript
// Collection names: snake_case, plural
const COLLECTIONS = {
  {{entity_1}}: '{{entity_1}}',
  user_permissions: 'user_permissions',
  {{entity_2}}: '{{entity_2}}'
};

// Field names: camelCase in code, snake_case in DB
interface {{EntityDocument}} {
  {{entityId}}: string;        // Maps to {{entity_id}} in database
  {{propertyName}}: string;    // Maps to {{property_name}} in database
  createdAt: Date;             // Maps to created_at in database
}
```

## Error Handling Patterns

### Custom Error Classes

```typescript
// Base error class
export class BaseError extends Error {
  constructor(
    public message: string,
    public code: string,
    public statusCode: number,
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Specific error classes
export class DatabaseConnectionError extends BaseError {
  constructor(message: string, originalError?: Error) {
    super(
      message,
      'DB_CONNECTION_ERROR',
      500,
      true
    );
    this.originalError = originalError;
  }
}

export class ValidationError extends BaseError {
  constructor(message: string, field?: string) {
    super(
      message,
      'VALIDATION_ERROR',
      400,
      true
    );
    this.field = field;
  }
}
```

### Error Handling Strategy

```typescript
// Service layer
async function getData(entityId: string): Promise<Entity> {
  try {
    const data = await databaseClient
      .db('{{database_name}}')
      .collection('{{collection_name}}')
      .findOne({ _id: entityId });
      
    if (!data) {
      throw new NotFoundError(`{{Entity}} ${entityId} not found`);
    }
    
    return mapToEntityModel(data);
  } catch (error) {
    // Log and re-throw known errors
    if (error instanceof BaseError) {
      logger.error('Known error in getData', { error, entityId });
      throw error;
    }
    
    // Wrap unknown errors
    logger.error('Unknown error in getData', { error, entityId });
    throw new DatabaseError('Failed to fetch {{entity}} data', error);
  }
}

// Controller layer
app.get('/{{entities}}/:id', async (req, res, next) => {
  try {
    const entity = await getData(req.params.id);
    res.json({ success: true, data: entity });
  } catch (error) {
    next(error); // Pass to error middleware
  }
});

// Global error middleware
app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
  if (error instanceof BaseError) {
    return res.status(error.statusCode).json({
      success: false,
      error: {
        code: error.code,
        message: error.message,
        ...(isDevelopment && { stack: error.stack })
      }
    });
  }
  
  // Unknown errors
  logger.error('Unhandled error', { error, path: req.path });
  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred'
    }
  });
});
```

## Logging Standards

### Log Levels

```typescript
// Use appropriate log levels
logger.debug('Detailed information for debugging', { userId, action });
logger.info('General information about application flow', { event: 'user_login' });
logger.warn('Warning about potential issues', { retryCount, maxRetries });
logger.error('Error that needs attention', { error, context });
logger.fatal('Critical error that requires immediate action', { error });
```

### Structured Logging

```typescript
// Always use structured logging with context
logger.info('{{Process}} completed', {
  entityId: entity.id,
  resultsFound: results.length,
  processingTime: Date.now() - startTime,
  threshold: config.threshold
});

// Include correlation IDs
logger.info('Processing request', {
  correlationId: req.headers['x-correlation-id'],
  userId: req.user.id,
  action: 'fetch_{{entity}}_data',
  entityId: req.params.id
});
```

### Security Considerations

```typescript
// Never log sensitive information
// Bad
logger.info('User login', { username, password });

// Good
logger.info('User login', { 
  username, 
  ipAddress: req.ip,
  userAgent: req.headers['user-agent']
});

// Sanitize error messages
function sanitizeError(error: Error): object {
  return {
    message: error.message,
    stack: isDevelopment ? error.stack : undefined,
    // Remove any sensitive data from error
    ...omit(error, ['password', 'apiKey', 'sshKey'])
  };
}
```