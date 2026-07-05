<script setup>
import { RouterView, RouterLink, useRouter } from 'vue-router'
import { computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useNotificationCount } from '@/composables/useNotificationCount'
import BottomNav from '@/components/BottomNav.vue'

const auth = useAuthStore()
const router = useRouter()
const { notificationCount, refresh: refreshNotificationCount } = useNotificationCount()

// Top-right header bell for every authenticated role (customer, vendor,
// admin) — the conventional spot for alerts across dashboard and consumer
// apps alike.
const showHeaderBell = computed(() => auth.isAuthenticated)

watch(() => [auth.isAuthenticated, auth.role], refreshNotificationCount, { immediate: true })

function goHome() {
  if (auth.role === 'vendor') router.push('/vendor/dashboard')
  else if (auth.role === 'admin') router.push('/admin')
  else router.push('/vendors')
}
</script>

<template>
  <div class="app-shell">
    <header>
      <div class="header-inner">
        <div class="brand" @click="goHome">
          <span class="brand-mark">CE</span>
          <span class="brand-name">CampusEats</span>
        </div>

        <RouterLink v-if="showHeaderBell" to="/notifications" class="notification-btn" aria-label="Notifications">
          <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" />
            <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
          </svg>
          <span v-if="notificationCount > 0" class="notification-badge">
            {{ notificationCount > 9 ? '9+' : notificationCount }}
          </span>
        </RouterLink>
      </div>
    </header>

    <div class="app-content">
      <RouterView />
    </div>

    <div class="bottom-nav-wrap">
      <BottomNav />
    </div>
  </div>
</template>

<style>
/* The whole shell — header, content, bottom nav — is capped here once, so
   every piece of chrome shares the exact same edges at every screen size
   instead of each having its own separate width rule. */
.app-shell {
  max-width: var(--app-width);
  margin: 0 auto;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
header {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--color-border);
  position: sticky;
  top: 0;
  z-index: 50;
  padding-top: env(safe-area-inset-top);
}
.header-inner {
  padding: 0.9rem 1.25rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}
.brand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}
.brand-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.9rem;
  height: 1.9rem;
  border-radius: var(--radius-sm);
  background: var(--color-primary);
  color: #fff;
  font-family: var(--font-heading);
  font-weight: 800;
  font-size: 0.75rem;
}
.brand-name {
  font-family: var(--font-heading);
  font-weight: 800;
  font-size: 1.1rem;
  color: var(--color-text);
  letter-spacing: -0.02em;
}
.notification-btn {
  position: relative;
  display: inline-flex;
  color: var(--color-primary);
  line-height: 1;
  text-decoration: none;
  transition: color 0.15s ease;
}
.notification-btn:hover {
  color: var(--color-primary-dark);
}
.notification-badge {
  position: absolute;
  top: -0.4rem;
  right: -0.55rem;
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
  border: 2px solid var(--color-surface);
}

.app-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.bottom-nav-wrap {
  position: sticky;
  bottom: 0;
  padding-bottom: env(safe-area-inset-bottom);
  background: var(--color-surface);
}

/* ---- shared, non-component-specific utility classes used across views ---- */
.btn-back {
  background: var(--color-surface-alt);
  color: var(--color-text-secondary);
  border: none;
  padding: 0.5rem 0.85rem;
  border-radius: var(--radius-md);
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
  margin-bottom: 1rem;
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  text-decoration: none;
}
.btn-back:hover {
  background: var(--color-border);
}
</style>
