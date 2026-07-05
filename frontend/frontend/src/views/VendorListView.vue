<template>
  <main class="vendors-screen">
    <div class="vendors-head">
      <h2 class="page-title">UTM Food Courts</h2>
      <p class="page-subtitle">Pick a stall and pre-order — skip the queue entirely</p>

      <AppInput v-model="search" placeholder="Search vendors..." icon="🔍" />

      <PillTabs v-model="filter" :options="filterOptions" class="filter-row" />
    </div>

    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <div v-if="loading" class="vendor-list">
      <div v-for="i in 3" :key="i" class="vendor-card skeleton-card">
        <SkeletonBlock height="4.5rem" width="4.5rem" radius="var(--radius-md)" />
        <div class="skeleton-lines">
          <SkeletonBlock height="0.9rem" width="70%" />
          <SkeletonBlock height="0.7rem" width="50%" />
          <SkeletonBlock height="0.7rem" width="40%" />
        </div>
      </div>
    </div>

    <EmptyState v-else-if="filteredVendors.length === 0" icon="🍽️" title="No vendors found" subtitle="Try a different search or filter." />

    <div v-else class="vendor-list">
      <RouterLink v-for="v in filteredVendors" :key="v.id" :to="`/vendors/${v.id}`" class="vendor-card">
        <FoodImage :src="v.image_url" :name="v.name" class="vendor-thumb" />
        <div class="vendor-info">
          <div class="vendor-info-top">
            <h3 class="vendor-name">{{ v.name }}</h3>
            <span class="vendor-rating">⭐ {{ v.rating ?? 'New' }}</span>
          </div>
          <p class="vendor-location">📍 {{ v.location }}</p>
          <div class="vendor-meta">
            <span class="prep-chip">⏱️ {{ v.prep_time_mins ? `${v.prep_time_mins} min` : 'N/A' }}</span>
            <span class="view-link">View menu →</span>
          </div>
        </div>
      </RouterLink>
    </div>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getVendors, ApiError } from '@/api/client'
import AppInput from '@/components/AppInput.vue'
import AppAlert from '@/components/AppAlert.vue'
import PillTabs from '@/components/PillTabs.vue'
import EmptyState from '@/components/EmptyState.vue'
import SkeletonBlock from '@/components/SkeletonBlock.vue'
import FoodImage from '@/components/FoodImage.vue'

const vendors = ref([])
const search = ref('')
const loading = ref(false)
const errorMessage = ref('')
const filter = ref('all')
let debounceTimer = null

const filterOptions = [
  { label: 'All', value: 'all' },
  { label: '⭐ Top Rated', value: 'top-rated' },
  { label: '⚡ Fastest Pickup', value: 'fastest' },
]

const filteredVendors = computed(() => {
  const list = [...vendors.value]
  if (filter.value === 'top-rated') return list.filter((v) => (v.rating ?? 0) >= 4.5)
  if (filter.value === 'fastest') return list.sort((a, b) => (a.prep_time_mins ?? 99) - (b.prep_time_mins ?? 99))
  return list
})

async function fetchVendors() {
  loading.value = true
  errorMessage.value = ''

  try {
    vendors.value = await getVendors(search.value)
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load vendors.'
  } finally {
    loading.value = false
  }
}

function debouncedFetch() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(fetchVendors, 300)
}

watch(search, debouncedFetch)
onMounted(fetchVendors)
</script>

<style scoped>
.vendors-screen {
  padding: 1.25rem 1.25rem 1.5rem;
  flex: 1;
  box-sizing: border-box;
}
.vendors-head {
  padding-top: 0.1rem;
  padding-bottom: 0.9rem;
}
.page-title {
  font-size: 1.3rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0 0 0.2rem 0;
}
.page-subtitle {
  font-size: 0.82rem;
  color: var(--color-text-secondary);
  margin: 0 0 0.9rem 0;
}
.filter-row {
  margin-top: 0.75rem;
}
.vendor-list {
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
}
.vendor-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 0.85rem;
  background: var(--color-surface);
  display: flex;
  gap: 0.9rem;
  text-decoration: none;
  color: inherit;
  box-shadow: var(--shadow-sm);
  transition:
    transform 0.15s ease,
    box-shadow 0.15s ease;
}
.vendor-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}
.vendor-thumb {
  width: 3.4rem;
  height: 3.4rem;
  font-size: 1.15rem;
}
.vendor-info {
  flex: 1;
  min-width: 0;
}
.vendor-info-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.5rem;
}
.vendor-name {
  margin: 0;
  font-size: 0.98rem;
  font-weight: 700;
  color: var(--color-text);
}
.vendor-rating {
  flex-shrink: 0;
  color: var(--color-accent);
  font-size: 0.8rem;
  font-weight: 700;
}
.vendor-location {
  margin: 0.3rem 0 0 0;
  font-size: 0.76rem;
  color: var(--color-text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.vendor-meta {
  margin-top: 0.6rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.prep-chip {
  font-size: 0.72rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  background: var(--color-surface-alt);
  padding: 0.2rem 0.55rem;
  border-radius: var(--radius-full);
}
.view-link {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--color-primary-dark);
}
.skeleton-card {
  align-items: center;
}
.skeleton-lines {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
</style>
