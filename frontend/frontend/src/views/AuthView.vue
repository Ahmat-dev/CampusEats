<template>
  <main class="auth-screen">
    <div class="auth-icon">{{ mode === 'login' ? '🔐' : '👋' }}</div>
    <h2 class="auth-heading">{{ mode === 'login' ? 'Welcome back' : 'Create your account' }}</h2>
    <p class="auth-subtext">
      {{
        mode === 'login'
          ? 'Log in to keep pre-ordering from your favorite stalls'
          : 'Join CampusEats to pre-order meals or run your own stall'
      }}
    </p>

    <form class="auth-form" @submit.prevent="handleSubmit">
      <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

      <template v-if="mode === 'register'">
        <AppInput v-model="name" label="Full name" placeholder="Your name" icon="🎓" required minlength="2" />
        <div class="field-gap" />
      </template>

      <AppInput
        v-model="email"
        type="email"
        label="Email"
        placeholder="you@student.utm.my"
        icon="✉️"
        required
        autocomplete="email"
      />
      <div class="field-gap" />
      <AppInput
        v-model="password"
        type="password"
        label="Password"
        :placeholder="mode === 'login' ? '••••••••' : 'At least 8 characters'"
        icon="🔒"
        required
        :minlength="mode === 'register' ? 8 : null"
        :autocomplete="mode === 'login' ? 'current-password' : 'new-password'"
      />

      <div v-if="mode === 'register'" class="role-field">
        <span class="role-label">I'm joining as a</span>
        <div class="role-picker">
          <button
            type="button"
            class="role-card"
            :class="{ active: role === 'customer' }"
            @click="role = 'customer'"
          >
            <span class="role-icon">🎓</span>
            <span>Student</span>
          </button>
          <button type="button" class="role-card" :class="{ active: role === 'vendor' }" @click="role = 'vendor'">
            <span class="role-icon">🏪</span>
            <span>Vendor</span>
          </button>
        </div>
      </div>

      <AppButton type="submit" block size="lg" class="submit-btn" :loading="loading">
        {{ submitLabel }}
      </AppButton>
    </form>

    <RouterLink :to="switchLink" class="switch-link">{{ switchLinkLabel }}</RouterLink>
  </main>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ApiError } from '@/api/client'
import { postAuthDestination } from '@/router/postAuthDestination'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import AppAlert from '@/components/AppAlert.vue'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const mode = computed(() => (route.name === 'register' ? 'register' : 'login'))

// A plain "Don't have an account? Sign up" link is the universal pattern for
// switching modes — carries the pending redirect (e.g. from a guest checkout
// bounce) over to whichever form the visitor picks next.
const switchLink = computed(() => ({
  path: mode.value === 'login' ? '/register' : '/login',
  query: route.query.redirect ? { redirect: route.query.redirect } : {},
}))
const switchLinkLabel = computed(() =>
  mode.value === 'login' ? "Don't have an account? Sign up" : 'Already have an account? Log in',
)

const name = ref('')
const email = ref('')
const password = ref('')
const role = ref('customer')
const loading = ref(false)
const errorMessage = ref('')

// Switching tabs shouldn't carry over an error from the other form.
watch(mode, () => {
  errorMessage.value = ''
})

const submitLabel = computed(() => {
  if (loading.value) return mode.value === 'login' ? 'Signing in…' : 'Creating account…'
  return mode.value === 'login' ? 'Log in' : 'Create account'
})

async function handleSubmit() {
  loading.value = true
  errorMessage.value = ''

  try {
    const user =
      mode.value === 'login'
        ? await auth.login(email.value, password.value)
        : await auth.register(name.value, email.value, password.value, role.value)
    router.push(postAuthDestination(router, route.query.redirect, user.role))
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Something went wrong. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-screen {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem 1.5rem;
  text-align: center;
  box-sizing: border-box;
}
.auth-icon {
  font-size: 2.75rem;
  margin-bottom: 0.75rem;
}
.auth-heading {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0 0 0.35rem 0;
}
.auth-subtext {
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  margin-bottom: 1.75rem;
}
.auth-form {
  width: 100%;
  text-align: left;
}
.field-gap {
  height: 0.85rem;
}
.role-field {
  margin-top: 1.1rem;
}
.role-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 0.5rem;
}
.role-picker {
  display: flex;
  gap: 0.6rem;
}
.role-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
  padding: 0.85rem;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-strong);
  background: var(--color-surface);
  font-size: 0.82rem;
  font-weight: 700;
  color: var(--color-text-secondary);
  cursor: pointer;
}
.role-card.active {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
  color: var(--color-primary-dark);
}
.role-icon {
  font-size: 1.3rem;
}
.submit-btn {
  margin-top: 1.5rem;
}
.switch-link {
  display: block;
  margin-top: 1.25rem;
  font-size: 0.8rem;
  color: var(--color-primary-dark);
  font-weight: 600;
  text-decoration: none;
}
</style>
