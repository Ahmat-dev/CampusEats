<template>
  <main class="orders-screen">
    <h2 class="page-title">Your orders</h2>

    <PillTabs v-model="activeStatus" :options="statusFilters" class="filter-row" />

    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <div v-if="loading" class="order-list">
      <div v-for="i in 2" :key="i" class="order-card">
        <SkeletonBlock height="0.9rem" width="40%" />
        <SkeletonBlock height="0.7rem" width="60%" />
      </div>
    </div>

    <EmptyState v-else-if="orders.length === 0" icon="📋" title="No orders yet" subtitle="Your pre-orders will show up here." />

    <div v-else class="order-list">
      <div v-for="order in orders" :key="order.id" class="order-card">
        <div class="order-header">
          <span class="order-id">Order #{{ order.id }}</span>
          <StatusBadge :status="order.status" />
        </div>
        <div class="order-meta">Pickup: {{ order.pickup_at }} · RM {{ order.total.toFixed(2) }}</div>
        <div class="order-items">{{ order.items.map((i) => `${i.qty}x ${i.name}`).join(', ') }}</div>

        <OrderStatusStepper :status="order.status" class="order-stepper" />

        <AppButton v-if="order.status === 'placed'" variant="danger" size="sm" @click="cancelOrder(order.id)">
          Cancel order
        </AppButton>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { api, ApiError } from '@/api/client'
import AppAlert from '@/components/AppAlert.vue'
import AppButton from '@/components/AppButton.vue'
import PillTabs from '@/components/PillTabs.vue'
import EmptyState from '@/components/EmptyState.vue'
import SkeletonBlock from '@/components/SkeletonBlock.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import OrderStatusStepper from '@/components/OrderStatusStepper.vue'

const orders = ref([])
const loading = ref(false)
const errorMessage = ref('')
const activeStatus = ref('')

const statusFilters = [
  { label: 'All', value: '' },
  { label: 'Placed', value: 'placed' },
  { label: 'Preparing', value: 'preparing' },
  { label: 'Ready', value: 'ready' },
  { label: 'Collected', value: 'collected' },
]

async function fetchOrders() {
  loading.value = true
  errorMessage.value = ''

  try {
    const query = activeStatus.value ? `?status=${activeStatus.value}` : ''
    orders.value = await api.get(`/api/orders${query}`, { auth: true })
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load orders.'
  } finally {
    loading.value = false
  }
}

async function cancelOrder(id) {
  try {
    await api.patch(`/api/orders/${id}/cancel`, {}, { auth: true })
    await fetchOrders()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not cancel order.'
  }
}

watch(activeStatus, fetchOrders)
onMounted(fetchOrders)
</script>

<style scoped>
.orders-screen {
  padding: 1rem 1.25rem 1.5rem;
  flex: 1;
  box-sizing: border-box;
}
.page-title {
  font-size: 1.3rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0 0 0.9rem 0;
}
.filter-row {
  margin-bottom: 1.1rem;
}
.order-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.order-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1rem;
  background: var(--color-surface);
}
.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.order-id {
  font-weight: 700;
  font-size: 0.9rem;
  color: var(--color-text);
}
.order-meta {
  font-size: 0.78rem;
  color: var(--color-text-secondary);
  margin: 0.35rem 0;
}
.order-items {
  font-size: 0.78rem;
  color: var(--color-text-secondary);
}
.order-stepper {
  margin: 1rem 0 0.25rem;
}
</style>
