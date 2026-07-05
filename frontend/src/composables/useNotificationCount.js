import { ref } from 'vue'
import { api } from '@/api/client'
import { useAuthStore } from '@/stores/auth'

// Shared across every consumer (header bell for vendors/admins, bottom-nav
// badge for customers) so there's one source of truth for "what needs this
// person's attention" — pickups ready to collect, new orders to start
// preparing, or vendor signups waiting on approval.
const notificationCount = ref(0)

export function useNotificationCount() {
  const auth = useAuthStore()

  async function refresh() {
    if (!auth.isAuthenticated) {
      notificationCount.value = 0
      return
    }

    try {
      if (auth.role === 'admin') {
        const pending = await api.get('/api/admin/vendors/pending', { auth: true })
        notificationCount.value = pending.length
      } else if (auth.role === 'vendor') {
        const placed = await api.get('/api/orders?status=placed', { auth: true })
        notificationCount.value = placed.length
      } else if (auth.role === 'customer') {
        const ready = await api.get('/api/orders?status=ready', { auth: true })
        notificationCount.value = ready.length
      }
    } catch {
      notificationCount.value = 0
    }
  }

  return { notificationCount, refresh }
}
