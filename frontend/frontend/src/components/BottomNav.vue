<script setup>
import { computed, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'
import { useNotificationCount } from '@/composables/useNotificationCount'

const route = useRoute()
const auth = useAuthStore()
const cart = useCartStore()
const { refresh: refreshNotificationCount } = useNotificationCount()

watch(() => [auth.isAuthenticated, route.fullPath], refreshNotificationCount, { immediate: true })

// Every role gets a top-right header bell for alerts now, so the bottom nav
// only carries the sections actually navigated between.
const items = computed(() => {
  if (!auth.isAuthenticated) {
    return [
      { to: '/vendors', match: ['vendors', 'vendor-menu'], icon: '🏪', label: 'Vendors' },
      { to: '/login', match: ['login', 'register'], icon: '👤', label: 'Log in' },
    ]
  }

  if (auth.role === 'vendor') {
    return [
      { to: '/vendor/dashboard', match: ['vendor-dashboard'], icon: '🏪', label: 'Dashboard' },
      { to: '/account', match: ['account'], icon: '👤', label: 'Account' },
    ]
  }

  if (auth.role === 'admin') {
    return [
      { to: '/admin', match: ['admin'], icon: '🛠️', label: 'Dashboard' },
      { to: '/account', match: ['account'], icon: '👤', label: 'Account' },
    ]
  }

  return [
    { to: '/vendors', match: ['vendors', 'vendor-menu'], icon: '🏪', label: 'Vendors' },
    { to: '/orders', match: ['orders'], icon: '📋', label: 'Orders' },
    { to: '/checkout', match: ['checkout', 'order-success'], icon: '🛒', label: 'Cart', badge: cart.totalCount },
    { to: '/account', match: ['account'], icon: '👤', label: 'Account' },
  ]
})
</script>

<template>
  <nav class="bottom-nav">
    <RouterLink
      v-for="item in items"
      :key="item.to"
      :to="item.to"
      class="nav-item"
      :class="{ active: item.match.includes(route.name) }"
    >
      <span class="nav-icon">
        {{ item.icon }}
        <span v-if="item.badge > 0" class="nav-badge">{{ item.badge > 9 ? '9+' : item.badge }}</span>
      </span>
      <span class="nav-label">{{ item.label }}</span>
    </RouterLink>
  </nav>
</template>

<style scoped>
.bottom-nav {
  position: sticky;
  bottom: 0;
  display: flex;
  gap: 0.25rem;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-top: 1px solid var(--color-border);
  padding: 0.5rem 0.5rem calc(0.5rem + env(safe-area-inset-bottom, 0px));
  z-index: 40;
}
.nav-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.2rem;
  padding: 0.4rem 0;
  text-decoration: none;
  color: var(--color-text-tertiary);
  border-radius: var(--radius-md);
  transition:
    color 0.15s ease,
    background-color 0.15s ease,
    transform 0.1s ease;
}
.nav-item:active {
  transform: scale(0.92);
}
.nav-item.active {
  color: var(--color-primary-dark);
  background: var(--color-primary-light);
}
.nav-icon {
  position: relative;
  font-size: 1.15rem;
}
.nav-label {
  font-size: 0.65rem;
  font-weight: 700;
}
.nav-badge {
  position: absolute;
  top: -0.35rem;
  right: -0.6rem;
  background: var(--color-accent);
  color: #fff;
  font-size: 0.6rem;
  font-weight: 700;
  min-width: 1.1rem;
  height: 1.1rem;
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 0.25rem;
}
</style>
