# Node.js API Patterns Template

## Overview
A production-ready Node.js API with Express/Fastify, featuring clean architecture, TypeScript, and enterprise patterns.

## When to Suggest
- Building RESTful APIs
- Need for JavaScript/TypeScript backend
- Microservices architecture
- Real-time features with WebSockets

## Core Specifications

### Technical Stack
- Node.js 20+ with TypeScript
- Express.js or Fastify
- Prisma or TypeORM for database
- JWT authentication
- Zod for validation
- Winston for logging
- Jest/Vitest for testing

### Project Structure
```
/app/backend/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── repositories/
│   ├── utils/
│   ├── types/
│   ├── validators/
│   └── server.ts
├── tests/
├── prisma/
└── Dockerfile
```

### Clean Architecture Layers

#### Controller Layer
```typescript
// src/controllers/user.controller.ts
import { Request, Response, NextFunction } from 'express';
import { UserService } from '@/services/user.service';
import { CreateUserDto, UpdateUserDto } from '@/validators/user.validator';
import { ApiResponse } from '@/utils/api-response';

export class UserController {
  constructor(private userService: UserService) {}

  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const { page = 1, limit = 10, search } = req.query;
      const result = await this.userService.findAll({
        page: Number(page),
        limit: Number(limit),
        search: search as string,
      });
      
      return ApiResponse.success(res, result);
    } catch (error) {
      next(error);
    }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await this.userService.findById(req.params.id);
      return ApiResponse.success(res, user);
    } catch (error) {
      next(error);
    }
  }

  async create(req: Request<{}, {}, CreateUserDto>, res: Response, next: NextFunction) {
    try {
      const user = await this.userService.create(req.body);
      return ApiResponse.created(res, user);
    } catch (error) {
      next(error);
    }
  }
}
```

#### Service Layer
```typescript
// src/services/user.service.ts
import { UserRepository } from '@/repositories/user.repository';
import { CreateUserDto, UpdateUserDto } from '@/validators/user.validator';
import { hashPassword } from '@/utils/crypto';
import { AppError } from '@/utils/errors';
import { PaginationParams } from '@/types';

export class UserService {
  constructor(private userRepository: UserRepository) {}

  async findAll(params: PaginationParams) {
    const { data, total } = await this.userRepository.findMany(params);
    
    return {
      data,
      meta: {
        total,
        page: params.page,
        limit: params.limit,
        totalPages: Math.ceil(total / params.limit),
      },
    };
  }

  async findById(id: string) {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new AppError('User not found', 404);
    }
    return user;
  }

  async create(data: CreateUserDto) {
    const exists = await this.userRepository.findByEmail(data.email);
    if (exists) {
      throw new AppError('Email already exists', 409);
    }

    const hashedPassword = await hashPassword(data.password);
    return this.userRepository.create({
      ...data,
      password: hashedPassword,
    });
  }
}
```

#### Repository Layer
```typescript
// src/repositories/user.repository.ts
import { PrismaClient } from '@prisma/client';
import { PaginationParams } from '@/types';

export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findMany({ page, limit, search }: PaginationParams) {
    const where = search
      ? {
          OR: [
            { name: { contains: search, mode: 'insensitive' } },
            { email: { contains: search, mode: 'insensitive' } },
          ],
        }
      : {};

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          createdAt: true,
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return { data, total };
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async create(data: any) {
    return this.prisma.user.create({ data });
  }
}
```

### Middleware Patterns

#### Authentication Middleware
```typescript
// src/middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '@/utils/jwt';
import { AppError } from '@/utils/errors';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      throw new AppError('No token provided', 401);
    }

    const decoded = await verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    next(new AppError('Invalid token', 401));
  }
};

export const authorize = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new AppError('Insufficient permissions', 403));
    }
    next();
  };
};
```

#### Validation Middleware
```typescript
// src/middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';
import { AppError } from '@/utils/errors';

export const validate = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        next(new AppError('Validation failed', 400, error.errors));
      } else {
        next(error);
      }
    }
  };
};
```

### Error Handling
```typescript
// src/utils/errors.ts
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public details?: any
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// src/middleware/error.middleware.ts
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: {
        message: err.message,
        details: err.details,
      },
    });
  }

  logger.error('Unhandled error:', err);
  
  res.status(500).json({
    success: false,
    error: {
      message: 'Internal server error',
    },
  });
};
```

### Route Organization
```typescript
// src/routes/index.ts
import { Router } from 'express';
import { userRoutes } from './user.routes';
import { authRoutes } from './auth.routes';
import { healthRoutes } from './health.routes';

export const createRouter = () => {
  const router = Router();

  router.use('/health', healthRoutes);
  router.use('/auth', authRoutes);
  router.use('/users', userRoutes);

  return router;
};

// src/routes/user.routes.ts
import { Router } from 'express';
import { UserController } from '@/controllers/user.controller';
import { authenticate, authorize } from '@/middleware/auth.middleware';
import { validate } from '@/middleware/validation.middleware';
import { createUserSchema, updateUserSchema } from '@/validators/user.validator';

const router = Router();
const userController = new UserController(userService);

router.get('/', authenticate, userController.getAll);
router.get('/:id', authenticate, userController.getById);
router.post('/', authenticate, authorize('admin'), validate(createUserSchema), userController.create);
router.put('/:id', authenticate, authorize('admin'), validate(updateUserSchema), userController.update);
router.delete('/:id', authenticate, authorize('admin'), userController.delete);

export { router as userRoutes };
```

### Database Connection
```typescript
// src/config/database.ts
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

export async function connectDatabase() {
  try {
    await prisma.$connect();
    logger.info('Database connected successfully');
  } catch (error) {
    logger.error('Database connection failed:', error);
    process.exit(1);
  }
}
```

### Server Setup
```typescript
// src/server.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createRouter } from './routes';
import { errorHandler } from './middleware/error.middleware';
import { requestLogger } from './middleware/logger.middleware';
import { connectDatabase } from './config/database';
import { config } from './config';

export async function createServer() {
  const app = express();

  // Middleware
  app.use(helmet());
  app.use(cors(config.cors));
  app.use(compression());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  app.use(requestLogger);

  // Routes
  app.use('/api/v1', createRouter());

  // Error handling
  app.use(errorHandler);

  // Database connection
  await connectDatabase();

  return app;
}

// src/index.ts
async function start() {
  try {
    const app = await createServer();
    const port = config.port || 3000;
    
    app.listen(port, () => {
      logger.info(`Server running on port ${port}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

start();
```

## Key Benefits
- Clean architecture with separation of concerns
- Type-safe with TypeScript
- Comprehensive error handling
- Database abstraction with repository pattern
- JWT authentication built-in
- Request validation with Zod
- Structured logging
- Docker-ready

## Environment Configuration
```env
# .env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:5173
```

## Docker Configuration
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
RUN npx prisma generate
EXPOSE 3000
CMD ["node", "dist/index.js"]
```