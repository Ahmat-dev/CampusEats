<template>
  <main class="dashboard-screen">
    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <!-- No vendor yet: onboarding form -->
    <template v-if="!loading && !myVendor">
      <h2 class="page-title">Set up your stall</h2>
      <p class="page-subtitle">Create your vendor listing. An admin needs to approve it before it appears to customers.</p>

      <form class="onboard-form" @submit.prevent="createVendor">
        <AppInput v-model="form.name" label="Stall name" placeholder="e.g. Kak Lah Nasi Lemak" required />
        <div class="field-gap" />
        <AppInput v-model="form.location" label="Location" placeholder="e.g. Block C, Counter 3" required />
        <div class="field-gap" />
        <AppInput v-model="form.opening_hours" label="Opening hours (optional)" placeholder="e.g. 8:00 AM - 4:00 PM" />
        <div class="field-gap" />
        <AppInput v-model.number="form.prep_time_mins" type="number" label="Avg. prep time in minutes (optional)" placeholder="15" />
        <AppButton type="submit" block size="lg" class="submit-btn" :loading="submitting">Create stall</AppButton>
      </form>
    </template>

    <!-- Has a vendor -->
    <template v-else-if="myVendor">
      <div class="vendor-status-card">
        <div class="vendor-status-top">
          <strong>{{ myVendor.name }}</strong>
          <StatusBadge :status="myVendor.status" />
        </div>
        <p v-if="myVendor.status === 'pending'" class="status-note pending">
          Waiting for admin approval — customers can't see this stall yet.
        </p>
        <p v-else-if="myVendor.status === 'rejected'" class="status-note rejected">This stall was rejected by an admin.</p>
      </div>

      <PillTabs v-model="tab" :options="tabOptions" class="tab-row" />

      <!-- Orders tab -->
      <template v-if="tab === 'orders'">
        <div v-if="ordersLoading" class="order-list">
          <div v-for="i in 2" :key="i" class="order-card"><SkeletonBlock height="0.9rem" width="50%" /></div>
        </div>
        <EmptyState v-else-if="orders.length === 0" icon="📋" title="No orders yet" />

        <div v-else class="order-list">
          <div v-for="order in orders" :key="order.id" class="order-card">
            <div class="order-header">
              <span class="order-id">Order #{{ order.id }}</span>
              <StatusBadge :status="order.status" />
            </div>
            <div class="order-meta">Pickup: {{ order.pickup_at }} · RM {{ order.total.toFixed(2) }}</div>
            <div class="order-items">{{ order.items.map((i) => `${i.qty}x ${i.name}`).join(', ') }}</div>
            <AppButton v-if="nextStatus(order.status)" size="sm" class="advance-btn" @click="advanceStatus(order)">
              Mark as {{ nextStatus(order.status) }} →
            </AppButton>
          </div>
        </div>
      </template>

      <!-- Menu tab -->
      <template v-else>
        <form class="menu-form" @submit.prevent="createMenuItem">
          <AppInput v-model="menuForm.name" label="Item name" placeholder="e.g. Nasi Lemak Ayam" required />
          <div class="field-gap" />
          <AppInput v-model="menuForm.category" label="Category" placeholder="e.g. Rice, Drinks" required />
          <div class="field-gap" />
          <AppInput v-model.number="menuForm.price" type="number" label="Price (RM)" placeholder="5.50" required />
          <div class="field-gap" />
          <AppInput v-model="menuForm.description" label="Description (optional)" placeholder="Short description" />
          <AppButton type="submit" block class="submit-btn" :loading="menuSubmitting">+ Add menu item</AppButton>
        </form>

        <div v-if="menuLoading" class="menu-list">
          <div v-for="i in 3" :key="i" class="menu-item-row"><SkeletonBlock height="0.9rem" width="60%" /></div>
        </div>
        <EmptyState v-else-if="menuItems.length === 0" icon="🍽️" title="No menu items yet" />

        <div v-else class="menu-list">
          <div v-for="item in menuItems" :key="item.id" class="menu-item-row">
            <FoodImage :src="item.image_url" :name="item.name" class="menu-item-thumb" />
            <div class="menu-item-body">
              <div class="menu-item-name">{{ item.name }}</div>
              <div class="menu-item-meta">{{ item.category }} · RM {{ item.price.toFixed(2) }}</div>
            </div>
            <div class="menu-item-actions">
              <ToggleSwitch :model-value="!!item.in_stock" @update:model-value="toggleStock(item)" />
              <button class="btn-icon-delete" aria-label="Delete item" @click="deleteMenuItem(item)">🗑️</button>
            </div>
          </div>
        </div>
      </template>
    </template>
  </main>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { api, ApiError } from '@/api/client'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import AppAlert from '@/components/AppAlert.vue'
import PillTabs from '@/components/PillTabs.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'
import SkeletonBlock from '@/components/SkeletonBlock.vue'
import FoodImage from '@/components/FoodImage.vue'
import ToggleSwitch from '@/components/ToggleSwitch.vue'

const loading = ref(true)
const submitting = ref(false)
const errorMessage = ref('')
const myVendor = ref(null)
const tab = ref('orders')
const tabOptions = [
  { label: 'Orders', value: 'orders' },
  { label: 'My menu', value: 'menu' },
]

const form = reactive({ name: '', location: '', opening_hours: '', prep_time_mins: null })

const orders = ref([])
const ordersLoading = ref(false)

const menuItems = ref([])
const menuLoading = ref(false)
const menuSubmitting = ref(false)
const menuForm = reactive({ name: '', category: '', price: null, description: '' })

const STATUS_SEQUENCE = ['placed', 'preparing', 'ready', 'collected']

function nextStatus(current) {
  const idx = STATUS_SEQUENCE.indexOf(current)
  return idx >= 0 && idx < STATUS_SEQUENCE.length - 1 ? STATUS_SEQUENCE[idx + 1] : null
}

async function loadMyVendor() {
  loading.value = true
  errorMessage.value = ''

  try {
    const vendors = await api.get('/api/vendors/mine', { auth: true })
    myVendor.value = vendors[0] ?? null
    if (myVendor.value) await fetchOrders()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load your stall.'
  } finally {
    loading.value = false
  }
}

async function createVendor() {
  submitting.value = true
  errorMessage.value = ''

  try {
    myVendor.value = await api.post('/api/vendors', { ...form }, { auth: true })
    await fetchOrders()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not create your stall.'
  } finally {
    submitting.value = false
  }
}

async function fetchOrders() {
  ordersLoading.value = true
  try {
    orders.value = await api.get('/api/orders', { auth: true })
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load orders.'
  } finally {
    ordersLoading.value = false
  }
}

async function advanceStatus(order) {
  const status = nextStatus(order.status)
  if (!status) return

  try {
    await api.patch(`/api/orders/${order.id}/status`, { status }, { auth: true })
    await fetchOrders()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not update order status.'
  }
}

async function fetchMenuItems() {
  menuLoading.value = true
  try {
    menuItems.value = await api.get(`/api/vendors/${myVendor.value.id}/menu-items`)
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load menu items.'
  } finally {
    menuLoading.value = false
  }
}

async function createMenuItem() {
  menuSubmitting.value = true
  errorMessage.value = ''

  try {
    await api.post(`/api/vendors/${myVendor.value.id}/menu-items`, { ...menuForm }, { auth: true })
    menuForm.name = ''
    menuForm.category = ''
    menuForm.price = null
    menuForm.description = ''
    await fetchMenuItems()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not add menu item.'
  } finally {
    menuSubmitting.value = false
  }
}

async function toggleStock(item) {
  try {
    await api.put(`/api/menu-items/${item.id}`, { in_stock: !item.in_stock }, { auth: true })
    await fetchMenuItems()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not update item.'
  }
}

async function deleteMenuItem(item) {
  try {
    await api.delete(`/api/menu-items/${item.id}`, { auth: true })
    await fetchMenuItems()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not delete item.'
  }
}

watch(tab, (value) => {
  if (value === 'menu' && menuItems.value.length === 0) fetchMenuItems()
})

onMounted(loadMyVendor)
</script>

<style scoped>
.dashboard-screen {
  padding: 1rem 1.25rem 1.5rem;
  flex: 1;
  box-sizing: border-box;
}
.page-title {
  font-size: 1.25rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0 0 0.3rem 0;
}
.page-subtitle {
  font-size: 0.82rem;
  color: var(--color-text-secondary);
  margin: 0 0 1.25rem 0;
}
.field-gap {
  height: 0.85rem;
}
.submit-btn {
  margin-top: 1rem;
}
.vendor-status-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1rem;
  margin-bottom: 1.1rem;
  background: var(--color-surface);
}
.vendor-status-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.status-note {
  font-size: 0.75rem;
  margin: 0.5rem 0 0 0;
}
.status-note.pending {
  color: var(--color-warning);
}
.status-note.rejected {
  color: var(--color-danger);
}
.tab-row {
  margin-bottom: 1.1rem;
}
.order-list,
.menu-list {
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}
.order-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
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
  font-size: 0.88rem;
}
.order-meta {
  font-size: 0.78rem;
  color: var(--color-text-secondary);
  margin: 0.35rem 0;
}
.order-items {
  font-size: 0.78rem;
  color: var(--color-text-secondary);
  margin-bottom: 0.6rem;
}
.advance-btn {
  margin-top: 0.2rem;
}
.menu-form {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1rem;
  margin-bottom: 1.25rem;
  background: var(--color-surface-alt);
}
.menu-item-row {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 0.65rem 0.8rem;
  display: flex;
  align-items: center;
  gap: 0.7rem;
  background: var(--color-surface);
}
.menu-item-thumb {
  width: 2.6rem;
  height: 2.6rem;
  font-size: 0.9rem;
}
.menu-item-body {
  flex: 1;
  min-width: 0;
}
.menu-item-name {
  font-weight: 700;
  font-size: 0.86rem;
  color: var(--color-text);
}
.menu-item-meta {
  font-size: 0.72rem;
  color: var(--color-text-secondary);
}
.menu-item-actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}
.btn-icon-delete {
  border: none;
  background: var(--color-danger-bg);
  color: var(--color-danger);
  width: 2rem;
  height: 2rem;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 0.85rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
</style>
