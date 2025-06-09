# Python FastAPI Defaults Template

## Overview
A modern, high-performance Python API using FastAPI with async support, automatic documentation, and type safety.

## When to Suggest
- Building high-performance APIs
- Need for async/await support
- Automatic API documentation required
- Python ecosystem preference
- Machine learning API endpoints

## Core Specifications

### Technical Stack
- Python 3.11+ with type hints
- FastAPI framework
- SQLAlchemy 2.0 with async support
- Alembic for migrations
- Pydantic for validation
- uvicorn for ASGI server
- pytest for testing

### Project Structure
```
/app/backend/
├── src/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── endpoints/
│   │   │   └── router.py
│   │   └── dependencies.py
│   ├── core/
│   │   ├── config.py
│   │   ├── security.py
│   │   └── database.py
│   ├── models/
│   ├── schemas/
│   ├── services/
│   ├── repositories/
│   └── main.py
├── tests/
├── alembic/
├── requirements.txt
└── Dockerfile
```

### Core Configuration
```python
# src/core/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import Optional

class Settings(BaseSettings):
    app_name: str = "FastAPI App"
    version: str = "1.0.0"
    debug: bool = False
    
    # Database
    database_url: str = "postgresql+asyncpg://user:pass@localhost/db"
    
    # Security
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # CORS
    cors_origins: list[str] = ["http://localhost:3000"]
    
    class Config:
        env_file = ".env"

@lru_cache()
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
```

### Database Setup with Async SQLAlchemy
```python
# src/core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from .config import settings

engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,
    pool_pre_ping=True,
    pool_size=5,
    max_overflow=10,
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

Base = declarative_base()

# Dependency
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

### Model Definition
```python
# src/models/user.py
from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from ..core.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

### Pydantic Schemas
```python
# src/schemas/user.py
from pydantic import BaseModel, EmailStr, ConfigDict
from datetime import datetime
from uuid import UUID
from typing import Optional

class UserBase(BaseModel):
    email: EmailStr
    username: str
    is_active: bool = True
    is_superuser: bool = False

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None

class UserInDB(UserBase):
    id: UUID
    created_at: datetime
    updated_at: Optional[datetime]
    
    model_config = ConfigDict(from_attributes=True)

class UserResponse(UserInDB):
    pass

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    username: Optional[str] = None
```

### Repository Pattern
```python
# src/repositories/user_repository.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional, List
from uuid import UUID
from ..models.user import User
from ..schemas.user import UserCreate, UserUpdate

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_by_id(self, user_id: UUID) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def get_by_username(self, username: str) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.username == username)
        )
        return result.scalar_one_or_none()
    
    async def get_multi(
        self, 
        skip: int = 0, 
        limit: int = 100,
        search: Optional[str] = None
    ) -> tuple[List[User], int]:
        query = select(User)
        count_query = select(func.count()).select_from(User)
        
        if search:
            search_filter = User.username.ilike(f"%{search}%") | User.email.ilike(f"%{search}%")
            query = query.where(search_filter)
            count_query = count_query.where(search_filter)
        
        query = query.offset(skip).limit(limit)
        
        result = await self.db.execute(query)
        count_result = await self.db.execute(count_query)
        
        return result.scalars().all(), count_result.scalar()
    
    async def create(self, user_in: UserCreate, hashed_password: str) -> User:
        user = User(
            email=user_in.email,
            username=user_in.username,
            hashed_password=hashed_password,
            is_active=user_in.is_active,
            is_superuser=user_in.is_superuser,
        )
        self.db.add(user)
        await self.db.flush()
        await self.db.refresh(user)
        return user
    
    async def update(self, user: User, user_in: UserUpdate) -> User:
        update_data = user_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(user, field, value)
        await self.db.flush()
        await self.db.refresh(user)
        return user
```

### Service Layer
```python
# src/services/user_service.py
from typing import Optional, List
from uuid import UUID
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from ..repositories.user_repository import UserRepository
from ..schemas.user import UserCreate, UserUpdate, UserResponse
from ..core.security import get_password_hash, verify_password

class UserService:
    def __init__(self, db: AsyncSession):
        self.repository = UserRepository(db)
    
    async def get_user(self, user_id: UUID) -> UserResponse:
        user = await self.repository.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        return UserResponse.model_validate(user)
    
    async def get_users(
        self, 
        skip: int = 0, 
        limit: int = 100,
        search: Optional[str] = None
    ) -> dict:
        users, total = await self.repository.get_multi(skip, limit, search)
        return {
            "data": [UserResponse.model_validate(user) for user in users],
            "total": total,
            "skip": skip,
            "limit": limit,
        }
    
    async def create_user(self, user_in: UserCreate) -> UserResponse:
        # Check if user exists
        existing_user = await self.repository.get_by_email(user_in.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        existing_username = await self.repository.get_by_username(user_in.username)
        if existing_username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )
        
        # Create user
        hashed_password = get_password_hash(user_in.password)
        user = await self.repository.create(user_in, hashed_password)
        return UserResponse.model_validate(user)
    
    async def update_user(self, user_id: UUID, user_in: UserUpdate) -> UserResponse:
        user = await self.repository.get_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        if user_in.password:
            user_in.password = get_password_hash(user_in.password)
        
        user = await self.repository.update(user, user_in)
        return UserResponse.model_validate(user)
```

### API Endpoints
```python
# src/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from uuid import UUID
from ....core.database import get_db
from ....services.user_service import UserService
from ....schemas.user import UserCreate, UserUpdate, UserResponse
from ....api.dependencies import get_current_active_user

router = APIRouter()

@router.get("/", response_model=dict)
async def get_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_active_user),
):
    """Get list of users with pagination and search"""
    service = UserService(db)
    return await service.get_users(skip, limit, search)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_active_user),
):
    """Get user by ID"""
    service = UserService(db)
    return await service.get_user(user_id)

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_active_superuser),
):
    """Create new user (superuser only)"""
    service = UserService(db)
    return await service.create_user(user_in)

@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: UUID,
    user_in: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_active_user),
):
    """Update user"""
    service = UserService(db)
    return await service.update_user(user_id, user_in)
```

### Main Application
```python
# src/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from .core.config import settings
from .core.database import engine
from .api.v1.router import api_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Starting up...")
    yield
    # Shutdown
    print("Shutting down...")
    await engine.dispose()

app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

### Testing
```python
# tests/test_users.py
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import uuid4

@pytest.mark.asyncio
async def test_create_user(
    client: AsyncClient,
    db: AsyncSession,
    superuser_token_headers: dict,
):
    data = {
        "email": "test@example.com",
        "username": "testuser",
        "password": "testpass123",
    }
    response = await client.post(
        "/api/v1/users/",
        json=data,
        headers=superuser_token_headers,
    )
    assert response.status_code == 201
    content = response.json()
    assert content["email"] == data["email"]
    assert content["username"] == data["username"]
    assert "id" in content
```

## Key Benefits
- Async/await for high performance
- Automatic API documentation
- Type safety with Pydantic
- Built-in validation
- Repository pattern for clean architecture
- Dependency injection
- Easy testing with pytest
- Production-ready structure

## Environment Configuration
```env
# .env
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/mydb
SECRET_KEY=your-secret-key-here
DEBUG=true
CORS_ORIGINS=["http://localhost:3000"]
```

## Docker Configuration
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```