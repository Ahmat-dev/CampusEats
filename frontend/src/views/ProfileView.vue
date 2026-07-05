<template>
  <main class="profile-screen">
    <div class="profile-header">
      <div class="profile-avatar">{{ initial }}</div>
      <div class="profile-header-text">
        <h2 class="profile-name">{{ auth.user?.name }}</h2>
        <p class="profile-email">{{ auth.user?.email }}</p>
        <span class="role-badge">{{ roleLabel }}</span>
      </div>
    </div>

    <div class="list-group">
      <button type="button" class="list-row list-row-danger" @click="logout">
        <span class="list-row-label">Log out</span>
      </button>
    </div>

    <p class="app-footer">CampusEats · v1.0</p>
  </main>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'

const auth = useAuthStore()
const cart = useCartStore()
const router = useRouter()

const initial = computed(() => auth.user?.name?.charAt(0).toUpperCase() ?? '?')
const roleLabel = computed(() => {
  if (auth.role === 'vendor') return 'Vendor'
  if (auth.role === 'admin') return 'Admin'
  return 'Student'
})

function logout() {
  auth.logout()
  cart.clearCart()
  router.push('/login')
}
</script>

<style scoped>
.profile-screen {
  padding: 1.75rem 1.25rem 1.5rem;
  flex: 1;
  box-sizing: border-box;
}
.profile-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.75rem;
}
.profile-avatar {
  flex-shrink: 0;
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 50%;
  background: var(--color-primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-heading);
  font-weight: 800;
  font-size: 1.3rem;
}
.profile-header-text {
  min-width: 0;
}
.profile-name {
  font-size: 1.05rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0;
}
.profile-email {
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  margin: 0.15rem 0 0.45rem 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.role-badge {
  background: var(--color-primary-light);
  color: var(--color-primary-dark);
  font-size: 0.65rem;
  font-weight: 700;
  padding: 0.25rem 0.7rem;
  border-radius: var(--radius-full);
  text-transform: uppercase;
  letter-spacing: 0.03em;
}
.list-group {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  background: var(--color-surface);
  overflow: hidden;
  margin-bottom: 1rem;
}
.list-row {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.9rem 1.1rem;
  border: none;
  background: none;
  text-decoration: none;
  color: var(--color-text);
  font-weight: 600;
  font-size: 0.86rem;
  font-family: inherit;
  cursor: pointer;
  text-align: left;
}
.list-row:not(:last-child) {
  border-bottom: 1px solid var(--color-border);
}
.list-row-danger {
  color: var(--color-danger);
  justify-content: flex-start;
  gap: 0.5rem;
}
.app-footer {
  text-align: center;
  font-size: 0.7rem;
  color: var(--color-text-tertiary);
  margin-top: 2rem;
}
</style>
