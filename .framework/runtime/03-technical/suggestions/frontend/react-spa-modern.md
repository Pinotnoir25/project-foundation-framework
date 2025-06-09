# React SPA Modern Template

## Overview
A modern single-page application using React with Vite, featuring a clean component architecture and modern tooling.

## When to Suggest
- Building client-side applications
- Need for fast development iteration
- Modern browser support only
- API-driven architectures

## Core Specifications

### Technical Stack
- React 18+ with TypeScript
- Vite for build tooling
- React Router for navigation
- Tanstack Query for data fetching
- Zustand for state management
- Tailwind CSS for styling

### Project Structure
```
/app/frontend/
├── src/
│   ├── components/
│   │   ├── common/
│   │   ├── features/
│   │   └── layouts/
│   ├── hooks/
│   ├── services/
│   ├── stores/
│   ├── types/
│   ├── utils/
│   └── App.tsx
├── public/
└── index.html
```

### Component Patterns

#### Feature-Based Organization
```typescript
// src/components/features/users/UserList.tsx
import { useUsers } from '@/hooks/queries/useUsers';
import { UserCard } from './UserCard';

export function UserList() {
  const { data: users, isLoading } = useUsers();
  
  if (isLoading) return <LoadingSpinner />;
  
  return (
    <div className="grid gap-4">
      {users?.map(user => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}
```

#### Custom Hooks Pattern
```typescript
// src/hooks/queries/useUsers.ts
import { useQuery } from '@tanstack/react-query';
import { userService } from '@/services/user.service';

export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: userService.getAll,
  });
}
```

#### Service Layer
```typescript
// src/services/user.service.ts
import { api } from '@/lib/api';
import type { User } from '@/types';

export const userService = {
  getAll: () => api.get<User[]>('/users'),
  getById: (id: string) => api.get<User>(`/users/${id}`),
  create: (data: CreateUserDto) => api.post<User>('/users', data),
  update: (id: string, data: UpdateUserDto) => api.put<User>(`/users/${id}`, data),
  delete: (id: string) => api.delete(`/users/${id}`),
};
```

### State Management with Zustand
```typescript
// src/stores/auth.store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  user: User | null;
  token: string | null;
  login: (credentials: LoginDto) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      login: async (credentials) => {
        const { user, token } = await authService.login(credentials);
        set({ user, token });
      },
      logout: () => set({ user: null, token: null }),
    }),
    {
      name: 'auth-storage',
    }
  )
);
```

### Routing Pattern
```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Layout } from '@/components/layouts/Layout';
import { ProtectedRoute } from '@/components/common/ProtectedRoute';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      retry: 1,
    },
  },
});

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<HomePage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route element={<ProtectedRoute />}>
              <Route path="/dashboard" element={<DashboardPage />} />
              <Route path="/users" element={<UsersPage />} />
            </Route>
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}
```

### Error Boundaries
```typescript
// src/components/common/ErrorBoundary.tsx
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <ErrorFallback error={this.state.error} />;
    }

    return this.props.children;
  }
}
```

### Performance Optimization
```typescript
// Lazy loading routes
const DashboardPage = lazy(() => import('@/pages/DashboardPage'));

// Memoization
const ExpensiveComponent = memo(({ data }) => {
  const processedData = useMemo(() => processData(data), [data]);
  return <div>{/* render */}</div>;
});

// Virtual scrolling for lists
import { useVirtualizer } from '@tanstack/react-virtual';
```

## Key Benefits
- Fast development with Vite HMR
- Type-safe with TypeScript
- Modern data fetching patterns
- Efficient state management
- Built-in performance optimizations
- Clean component architecture

## Environment Configuration
```env
# .env
VITE_API_URL=http://localhost:3000/api
VITE_APP_NAME=My React App
```

## Build Configuration
```json
// package.json scripts
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext ts,tsx",
    "type-check": "tsc --noEmit"
  }
}
```