<template>
  <main class="notifications-screen">
    <h2 class="page-title">Notifications</h2>

    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <div v-if="loading" class="notif-list">
      <div v-for="i in 3" :key="i" class="notif-card"><SkeletonBlock height="0.9rem" width="70%" /></div>
    </div>

    <EmptyState
      v-else-if="notifications.length === 0"
      icon="🔔"
      title="You're all caught up"
      subtitle="No new notifications right now."
    />

    <div v-else class="notif-list">
      <RouterLink
        v-for="n in notifications"
        :key="n.key"
        :to="n.link"
        class="notif-card"
        :class="{ highlight: n.highlight }"
      >
        <span class="notif-icon">{{ n.icon }}</span>
        <div class="notif-body">
          <p class="notif-message">{{ n.message }}</p>
          <p class="notif-time">{{ n.time }}</p>
        </div>
      </RouterLink>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { api, ApiError } from '@/api/client'
import { useAuthStore } from '@/stores/auth'
import AppAlert from '@/components/AppAlert.vue'
import EmptyState from '@/components/EmptyState.vue'
import SkeletonBlock from '@/components/SkeletonBlock.vue'

const auth = useAuthStore()
const loading = ref(false)
const errorMessage = ref('')
const rawOrders = ref([])
const rawPending = ref([])
const myVendor = ref(null)

const VENDOR_STATUS_MESSAGES = {
  approved: { icon: '🎉', highlight: true, text: (v) => `${v.name} was approved — customers can now find and order from you!` },
  rejected: { icon: '❌', highlight: false, text: (v) => `${v.name}'s application was rejected by an admin` },
}

// There's no notifications table in the backend — these are derived straight
// from each order's current status, phrased the way a customer or vendor
// would actually want to read it, rather than just linking to the raw order list.
const CUSTOMER_MESSAGES = {
  placed: { icon: '📝', highlight: false, text: (o) => `Order #${o.id} placed — waiting for the stall to start preparing` },
  preparing: { icon: '👨‍🍳', highlight: false, text: (o) => `Order #${o.id} is being prepared` },
  ready: { icon: '🔔', highlight: true, text: (o) => `Order #${o.id} is ready for pickup!` },
  collected: { icon: '✅', highlight: false, text: (o) => `Order #${o.id} completed — enjoy your meal!` },
  cancelled: { icon: '❌', highlight: false, text: (o) => `Order #${o.id} was cancelled` },
}

const VENDOR_MESSAGES = {
  placed: { icon: '🆕', highlight: true, text: (o) => `New order #${o.id} received — RM ${o.total.toFixed(2)}` },
  preparing: { icon: '👨‍🍳', highlight: false, text: (o) => `Order #${o.id} is being prepared` },
  ready: { icon: '🔔', highlight: false, text: (o) => `Order #${o.id} marked ready for pickup` },
  collected: { icon: '✅', highlight: false, text: (o) => `Order #${o.id} was collected` },
  cancelled: { icon: '❌', highlight: false, text: (o) => `Order #${o.id} was cancelled by the customer` },
}

function timeAgo(dateStr) {
  if (!dateStr) return ''
  const minutes = Math.floor((Date.now() - new Date(dateStr).getTime()) / 60000)
  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes} min ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours} hr ago`
  const days = Math.floor(hours / 24)
  return `${days} day${days > 1 ? 's' : ''} ago`
}

const notifications = computed(() => {
  if (auth.role === 'admin') {
    return rawPending.value.map((v) => ({
      key: `vendor-${v.id}`,
      icon: '🏪',
      message: `${v.name} is awaiting approval`,
      time: 'Pending review',
      link: '/admin',
      highlight: true,
    }))
  }

  const messages = auth.role === 'vendor' ? VENDOR_MESSAGES : CUSTOMER_MESSAGES
  const link = auth.role === 'vendor' ? '/vendor/dashboard' : '/orders'

  const orderNotifications = [...rawOrders.value]
    .sort((a, b) => b.id - a.id)
    .map((order) => {
      const entry = messages[order.status] ?? { icon: '📦', highlight: false, text: () => `Order #${order.id} — ${order.status}` }
      return {
        key: `order-${order.id}`,
        icon: entry.icon,
        message: entry.text(order),
        time: timeAgo(order.created_at),
        link,
        highlight: entry.highlight,
      }
    })

  if (auth.role !== 'vendor' || !myVendor.value || myVendor.value.status === 'pending') {
    return orderNotifications
  }

  // A vendor's own approval/rejection matters more than any single order, so
  // it leads the feed rather than getting buried under order activity.
  const statusEntry = VENDOR_STATUS_MESSAGES[myVendor.value.status]
  const stallNotification = {
    key: `vendor-status-${myVendor.value.id}`,
    icon: statusEntry.icon,
    message: statusEntry.text(myVendor.value),
    time: 'Stall status',
    link: '/vendor/dashboard',
    highlight: statusEntry.highlight,
  }
  return [stallNotification, ...orderNotifications]
})

async function load() {
  loading.value = true
  errorMessage.value = ''

  try {
    if (auth.role === 'admin') {
      rawPending.value = await api.get('/api/admin/vendors/pending', { auth: true })
    } else if (auth.role === 'vendor') {
      const [orders, vendors] = await Promise.all([
        api.get('/api/orders', { auth: true }),
        api.get('/api/vendors/mine', { auth: true }),
      ])
      rawOrders.value = orders
      myVendor.value = vendors[0] ?? null
    } else {
      rawOrders.value = await api.get('/api/orders', { auth: true })
    }
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load notifications.'
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.notifications-screen {
  padding: 1rem 1.25rem 1.5rem;
  flex: 1;
  box-sizing: border-box;
}
.page-title {
  font-size: 1.3rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0 0 1rem 0;
}
.notif-list {
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}
.notif-card {
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
  padding: 0.85rem;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  text-decoration: none;
  color: inherit;
}
.notif-card.highlight {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
}
.notif-icon {
  font-size: 1.3rem;
  flex-shrink: 0;
  line-height: 1.3;
}
.notif-body {
  flex: 1;
  min-width: 0;
}
.notif-message {
  margin: 0;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
  line-height: 1.4;
}
.notif-time {
  margin: 0.25rem 0 0 0;
  font-size: 0.7rem;
  color: var(--color-text-secondary);
}
</style>
