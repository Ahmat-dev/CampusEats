<template>
  <main class="admin-screen">
    <h2 class="page-title">Admin panel</h2>

    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <PillTabs v-model="tab" :options="tabOptions" class="tab-row" />

    <template v-if="tab === 'pending'">
      <div v-if="pendingLoading" class="pending-list">
        <div v-for="i in 2" :key="i" class="pending-card"><SkeletonBlock height="0.9rem" width="50%" /></div>
      </div>
      <EmptyState v-else-if="pendingVendors.length === 0" icon="✅" title="No vendors awaiting approval" />

      <div v-else class="pending-list">
        <div v-for="v in pendingVendors" :key="v.id" class="pending-card">
          <div class="pending-name">{{ v.name }}</div>
          <div class="pending-location">📍 {{ v.location }}</div>
          <div class="pending-actions">
            <AppButton block @click="decide(v.id, 'approved')">Approve</AppButton>
            <AppButton block variant="danger" @click="decide(v.id, 'rejected')">Reject</AppButton>
          </div>
        </div>
      </div>
    </template>

    <template v-else-if="tab === 'all'">
      <div v-if="allVendorsLoading" class="pending-list">
        <div v-for="i in 3" :key="i" class="pending-card"><SkeletonBlock height="0.9rem" width="50%" /></div>
      </div>
      <EmptyState v-else-if="allVendors.length === 0" icon="🏪" title="No vendors yet" />

      <div v-else class="pending-list">
        <div v-for="v in allVendors" :key="v.id" class="vendor-manage-card">
          <div class="vendor-manage-top">
            <div>
              <div class="pending-name">{{ v.name }}</div>
              <div class="pending-location">📍 {{ v.location }}</div>
              <div class="vendor-owner">{{ v.owner_email }}</div>
            </div>
            <div class="vendor-badges">
              <StatusBadge :status="v.status" />
              <span class="suspended-badge" v-if="!v.is_active">Suspended</span>
            </div>
          </div>
          <div class="vendor-manage-actions">
            <div class="active-toggle">
              <ToggleSwitch :model-value="v.is_active" @update:model-value="toggleActive(v)" />
              <span>{{ v.is_active ? 'Active' : 'Suspended' }}</span>
            </div>
            <button class="btn-icon-delete" aria-label="Delete vendor" @click="removeVendor(v)">🗑️</button>
          </div>
        </div>
      </div>
    </template>

    <template v-else>
      <div v-if="analyticsLoading" class="stat-row">
        <SkeletonBlock height="4.5rem" />
        <SkeletonBlock height="4.5rem" />
      </div>

      <div v-else-if="analytics" class="stat-row">
        <div class="stat-card">
          <div class="stat-value">{{ analytics.total_orders }}</div>
          <div class="stat-label">Total orders</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">RM {{ analytics.total_revenue.toFixed(2) }}</div>
          <div class="stat-label">Revenue (collected)</div>
        </div>
      </div>

      <h3 class="section-title">By vendor</h3>
      <div class="vendor-stat-list">
        <div v-for="v in analytics?.by_vendor" :key="v.vendor_id" class="vendor-stat-row">
          <span>{{ v.vendor_name }}</span>
          <span class="vendor-stat-value">{{ v.order_count }} orders · RM {{ v.revenue.toFixed(2) }}</span>
        </div>
      </div>
    </template>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { api, ApiError } from '@/api/client'
import AppAlert from '@/components/AppAlert.vue'
import AppButton from '@/components/AppButton.vue'
import PillTabs from '@/components/PillTabs.vue'
import EmptyState from '@/components/EmptyState.vue'
import SkeletonBlock from '@/components/SkeletonBlock.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import ToggleSwitch from '@/components/ToggleSwitch.vue'

const tab = ref('pending')
const tabOptions = [
  { label: 'Pending vendors', value: 'pending' },
  { label: 'All vendors', value: 'all' },
  { label: 'Analytics', value: 'analytics' },
]
const errorMessage = ref('')

const pendingVendors = ref([])
const pendingLoading = ref(false)

const allVendors = ref([])
const allVendorsLoading = ref(false)

const analytics = ref(null)
const analyticsLoading = ref(false)

async function fetchPending() {
  pendingLoading.value = true
  try {
    pendingVendors.value = await api.get('/api/admin/vendors/pending', { auth: true })
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load pending vendors.'
  } finally {
    pendingLoading.value = false
  }
}

async function decide(vendorId, status) {
  try {
    await api.patch(`/api/admin/vendors/${vendorId}/approve`, { status }, { auth: true })
    await fetchPending()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not update vendor.'
  }
}

async function fetchAllVendors() {
  allVendorsLoading.value = true
  try {
    allVendors.value = await api.get('/api/admin/vendors', { auth: true })
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load vendors.'
  } finally {
    allVendorsLoading.value = false
  }
}

async function toggleActive(vendor) {
  try {
    await api.patch(`/api/admin/vendors/${vendor.id}/suspend`, { is_active: !vendor.is_active }, { auth: true })
    await fetchAllVendors()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not update vendor.'
  }
}

async function removeVendor(vendor) {
  if (!confirm(`Delete "${vendor.name}"? This cannot be undone.`)) return

  try {
    await api.delete(`/api/vendors/${vendor.id}`, { auth: true })
    await fetchAllVendors()
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not delete vendor.'
  }
}

async function fetchAnalytics() {
  analyticsLoading.value = true
  try {
    analytics.value = await api.get('/api/admin/analytics/summary', { auth: true })
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load analytics.'
  } finally {
    analyticsLoading.value = false
  }
}

onMounted(() => {
  fetchPending()
  fetchAllVendors()
  fetchAnalytics()
})
</script>

<style scoped>
.admin-screen {
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
.tab-row {
  margin-bottom: 1.1rem;
}
.pending-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.pending-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 1rem;
  background: var(--color-surface);
}
.pending-name {
  font-weight: 700;
  font-size: 0.92rem;
  color: var(--color-text);
}
.pending-location {
  font-size: 0.75rem;
  color: var(--color-text-secondary);
  margin: 0.25rem 0 0.85rem 0;
}
.pending-actions {
  display: flex;
  gap: 0.6rem;
}
.vendor-manage-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 1rem;
  background: var(--color-surface);
}
.vendor-manage-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.6rem;
}
.vendor-owner {
  font-size: 0.72rem;
  color: var(--color-text-secondary);
}
.vendor-badges {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.35rem;
  flex-shrink: 0;
}
.suspended-badge {
  display: inline-flex;
  font-size: 0.68rem;
  font-weight: 700;
  padding: 0.28rem 0.7rem;
  border-radius: var(--radius-full);
  background: var(--color-danger-bg);
  color: var(--color-danger);
}
.vendor-manage-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.85rem;
  padding-top: 0.85rem;
  border-top: 1px solid var(--color-border);
}
.active-toggle {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text-secondary);
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
.stat-row {
  display: flex;
  gap: 0.75rem;
}
.stat-card {
  flex: 1;
  background: var(--color-primary-light);
  border: 1px solid var(--color-primary-light);
  border-radius: var(--radius-lg);
  padding: 1.1rem;
  text-align: center;
}
.stat-value {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--color-primary-dark);
  font-family: var(--font-heading);
}
.stat-label {
  font-size: 0.7rem;
  color: var(--color-primary-dark);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.02em;
  margin-top: 0.25rem;
}
.section-title {
  font-size: 0.85rem;
  font-weight: 700;
  margin: 1.5rem 0 0.6rem 0;
  color: var(--color-text-secondary);
}
.vendor-stat-list {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  overflow: hidden;
  background: var(--color-surface);
}
.vendor-stat-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  padding: 0.75rem 0.9rem;
  border-bottom: 1px solid var(--color-border);
}
.vendor-stat-row:last-child {
  border-bottom: none;
}
.vendor-stat-value {
  color: var(--color-text-secondary);
}
</style>
