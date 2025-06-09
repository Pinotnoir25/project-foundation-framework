# Vue Enterprise Template

## Overview
An enterprise-ready Vue 3 application with Composition API, TypeScript, and comprehensive tooling for large-scale applications.

## When to Suggest
- Enterprise applications requiring progressive enhancement
- Teams familiar with Vue ecosystem
- Need for gradual migration paths
- Template-based component preferences

## Core Specifications

### Technical Stack
- Vue 3 with TypeScript
- Vite for build tooling
- Vue Router 4 for navigation
- Pinia for state management
- VueUse for composables
- Element Plus or Vuetify 3 for UI components
- Tailwind CSS for custom styling

### Project Structure
```
/app/frontend/
├── src/
│   ├── assets/
│   ├── components/
│   │   ├── common/
│   │   ├── features/
│   │   └── layouts/
│   ├── composables/
│   ├── directives/
│   ├── plugins/
│   ├── router/
│   ├── services/
│   ├── stores/
│   ├── types/
│   ├── utils/
│   ├── views/
│   └── App.vue
```

### Component Patterns

#### Composition API with TypeScript
```vue
<!-- src/components/features/users/UserList.vue -->
<template>
  <div class="user-list">
    <div v-if="isLoading" class="loading">
      <el-skeleton :rows="5" animated />
    </div>
    <div v-else class="grid gap-4">
      <UserCard 
        v-for="user in users" 
        :key="user.id" 
        :user="user"
        @edit="handleEdit"
        @delete="handleDelete"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useUsers } from '@/composables/useUsers'
import { useRouter } from 'vue-router'
import UserCard from './UserCard.vue'
import type { User } from '@/types'

const router = useRouter()
const { users, isLoading, deleteUser } = useUsers()

const handleEdit = (user: User) => {
  router.push(`/users/${user.id}/edit`)
}

const handleDelete = async (user: User) => {
  await ElMessageBox.confirm(
    `Delete user ${user.name}?`,
    'Confirm',
    { type: 'warning' }
  )
  await deleteUser(user.id)
}
</script>
```

#### Composables Pattern
```typescript
// src/composables/useUsers.ts
import { ref, computed } from 'vue'
import { useQuery, useMutation, useQueryClient } from '@tanstack/vue-query'
import { userService } from '@/services/user.service'
import { ElMessage } from 'element-plus'
import type { User } from '@/types'

export function useUsers() {
  const queryClient = useQueryClient()
  
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: userService.getAll,
  })
  
  const deleteUserMutation = useMutation({
    mutationFn: userService.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      ElMessage.success('User deleted successfully')
    },
    onError: () => {
      ElMessage.error('Failed to delete user')
    },
  })
  
  return {
    users: computed(() => users.value ?? []),
    isLoading,
    deleteUser: deleteUserMutation.mutate,
  }
}
```

### State Management with Pinia
```typescript
// src/stores/auth.store.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/services/auth.service'
import type { User, LoginDto } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  
  const isAuthenticated = computed(() => !!token.value)
  const userRole = computed(() => user.value?.role ?? 'guest')
  
  async function login(credentials: LoginDto) {
    try {
      const response = await authService.login(credentials)
      user.value = response.user
      token.value = response.token
      localStorage.setItem('token', response.token)
    } catch (error) {
      throw error
    }
  }
  
  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }
  
  function initAuth() {
    const savedToken = localStorage.getItem('token')
    if (savedToken) {
      token.value = savedToken
      // Verify token and fetch user
    }
  }
  
  return {
    user,
    token,
    isAuthenticated,
    userRole,
    login,
    logout,
    initAuth,
  }
})
```

### Router with Guards
```typescript
// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth.store'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/HomePage.vue'),
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/DashboardPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/users/UsersPage.vue'),
        meta: { requiresAuth: true, roles: ['admin'] },
      },
    ],
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/LoginPage.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (to.meta.roles && !to.meta.roles.includes(authStore.userRole)) {
    next({ name: 'Forbidden' })
  } else {
    next()
  }
})

export default router
```

### Global Error Handling
```typescript
// src/plugins/error-handler.ts
import { App } from 'vue'
import { ElMessage } from 'element-plus'

export default {
  install(app: App) {
    app.config.errorHandler = (error, instance, info) => {
      console.error('Global error:', error)
      ElMessage.error('An unexpected error occurred')
      
      // Send to error tracking service
      if (import.meta.env.PROD) {
        // Sentry.captureException(error)
      }
    }
  }
}
```

### Form Validation
```vue
<!-- Using VeeValidate -->
<template>
  <Form @submit="onSubmit" :validation-schema="schema">
    <Field name="email" v-slot="{ field, errors }">
      <el-form-item label="Email" :error="errors[0]">
        <el-input v-bind="field" type="email" />
      </el-form-item>
    </Field>
    
    <Field name="password" v-slot="{ field, errors }">
      <el-form-item label="Password" :error="errors[0]">
        <el-input v-bind="field" type="password" show-password />
      </el-form-item>
    </Field>
    
    <el-button type="primary" native-type="submit">
      Submit
    </el-button>
  </Form>
</template>

<script setup lang="ts">
import { Form, Field } from 'vee-validate'
import * as yup from 'yup'

const schema = yup.object({
  email: yup.string().email().required(),
  password: yup.string().min(8).required(),
})

const onSubmit = (values: any) => {
  console.log('Form submitted:', values)
}
</script>
```

### Performance Optimization
```typescript
// Async components
const UserProfile = defineAsyncComponent(() => 
  import('./components/UserProfile.vue')
)

// Keep-alive for route caching
<router-view v-slot="{ Component }">
  <keep-alive :include="['Dashboard', 'UserList']">
    <component :is="Component" />
  </keep-alive>
</router-view>

// Virtual scrolling
import { VirtualList } from '@tanstack/vue-virtual'
```

## Key Benefits
- Enterprise-ready architecture
- Strong TypeScript support
- Comprehensive state management
- Built-in UI component library
- Advanced routing capabilities
- Form validation out of the box
- Vue DevTools integration

## Environment Configuration
```env
# .env
VITE_API_URL=http://localhost:3000/api
VITE_APP_TITLE=My Enterprise App
```

## Testing Setup
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './tests/setup.ts',
  },
})
```