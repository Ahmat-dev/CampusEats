<template>
  <main class="menu-screen">
    <RouterLink to="/vendors" class="btn-back">← Change stall</RouterLink>

    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <template v-if="vendor">
      <div class="vendor-hero">
        <FoodImage :src="vendor.image_url" :name="vendor.name" class="vendor-hero-img" />
        <div class="vendor-hero-info">
          <h2 class="vendor-hero-name">{{ vendor.name }}</h2>
          <div class="vendor-hero-meta">
            <span>⭐ {{ vendor.rating ?? 'New' }}</span>
            <span>·</span>
            <span>⏱️ {{ vendor.prep_time_mins ? `${vendor.prep_time_mins} min` : 'N/A' }}</span>
          </div>
          <p class="vendor-hero-location">📍 {{ vendor.location }}</p>
        </div>
      </div>

      <div class="menu-controls">
        <AppInput v-model="searchQuery" placeholder="Search dishes, drinks..." icon="🔍" />
        <PillTabs v-model="activeCategory" :options="categoryOptions" class="category-row" />
      </div>

      <div class="menu-items">
        <EmptyState v-if="filteredMenuItems.length === 0" icon="🔎" title="No items match" subtitle="Try another search term or category." />

        <div v-for="item in filteredMenuItems" :key="item.id" class="menu-card">
          <FoodImage :src="item.image_url" :name="item.name" emoji="🍴" class="menu-thumb" />
          <div class="menu-card-body">
            <div class="menu-card-name">{{ item.name }}</div>
            <div class="menu-card-desc">{{ item.description }}</div>
            <div class="menu-card-price">RM {{ item.price.toFixed(2) }}</div>
          </div>
          <div class="menu-card-action">
            <QtyStepper v-if="item.in_stock && qtyOf(item.id) > 0" size="sm" :qty="qtyOf(item.id)" @increase="handleAdd(item)" @decrease="cartStore.removeOne(item.id)" />
            <AppButton v-else-if="item.in_stock" size="sm" @click="handleAdd(item)">+ Add</AppButton>
            <span v-else class="sold-out">Sold out</span>
          </div>
        </div>
      </div>
    </template>

    <div class="cart-spacer" v-if="cartStore.totalCount > 0" />
    <RouterLink v-if="cartStore.totalCount > 0" to="/checkout" class="floating-cart-bar">
      <span class="floating-cart-count">{{ cartStore.totalCount }} item{{ cartStore.totalCount > 1 ? 's' : '' }}</span>
      <span class="floating-cart-label">View basket</span>
      <span class="floating-cart-total">RM {{ cartStore.cartTotal }}</span>
    </RouterLink>
  </main>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { getVendor, getMenuItems, ApiError } from '@/api/client'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import AppInput from '@/components/AppInput.vue'
import AppAlert from '@/components/AppAlert.vue'
import AppButton from '@/components/AppButton.vue'
import PillTabs from '@/components/PillTabs.vue'
import EmptyState from '@/components/EmptyState.vue'
import FoodImage from '@/components/FoodImage.vue'
import QtyStepper from '@/components/QtyStepper.vue'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const auth = useAuthStore()

const vendor = ref(null)
const menuItems = ref([])
const errorMessage = ref('')
const searchQuery = ref('')
const activeCategory = ref('All')

const categoryOptions = computed(() => [
  { label: 'All', value: 'All' },
  ...[...new Set(menuItems.value.map((item) => item.category))].map((c) => ({ label: c, value: c })),
])

const filteredMenuItems = computed(() => {
  return menuItems.value.filter((item) => {
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesCategory = activeCategory.value === 'All' || item.category === activeCategory.value
    return matchesSearch && matchesCategory
  })
})

function qtyOf(itemId) {
  return cartStore.items.find((i) => i.id === itemId)?.qty ?? 0
}

function handleAdd(item) {
  if (!auth.isAuthenticated) {
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  cartStore.addToCart(item)
}

async function loadVendor(vendorId) {
  errorMessage.value = ''

  try {
    const [vendorData, items] = await Promise.all([getVendor(vendorId), getMenuItems(vendorId)])
    vendor.value = vendorData
    menuItems.value = items
    cartStore.setVendor(vendorData.id, vendorData.name)
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load this vendor.'
  }
}

onMounted(() => loadVendor(route.params.id))
watch(() => route.params.id, (id) => loadVendor(id))
</script>

<style scoped>
.menu-screen {
  padding: 1rem 1.25rem 1.5rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}
.vendor-hero {
  display: flex;
  gap: 1rem;
  align-items: center;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 1rem;
  margin-bottom: 1.25rem;
  box-shadow: var(--shadow-sm);
}
.vendor-hero-img {
  width: 4rem;
  height: 4rem;
  font-size: 1.4rem;
}
.vendor-hero-name {
  margin: 0;
  font-size: 1.05rem;
  font-weight: 800;
  color: var(--color-text);
}
.vendor-hero-meta {
  display: flex;
  gap: 0.4rem;
  font-size: 0.8rem;
  color: var(--color-accent);
  font-weight: 700;
  margin-top: 0.3rem;
}
.vendor-hero-location {
  margin: 0.3rem 0 0 0;
  font-size: 0.75rem;
  color: var(--color-text-secondary);
}
.menu-controls {
  margin-bottom: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.menu-items {
  flex: 1;
}
.menu-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 0.7rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: var(--color-surface);
}
.menu-thumb {
  width: 3.4rem;
  height: 3.4rem;
  font-size: 1.15rem;
}
.menu-card-body {
  flex: 1;
  min-width: 0;
}
.menu-card-name {
  font-weight: 700;
  color: var(--color-text);
  font-size: 0.88rem;
}
.menu-card-desc {
  font-size: 0.74rem;
  color: var(--color-text-secondary);
  margin: 0.15rem 0 0.35rem 0;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}
.menu-card-price {
  color: var(--color-primary-dark);
  font-weight: 800;
  font-size: 0.85rem;
}
.menu-card-action {
  flex-shrink: 0;
}
.sold-out {
  font-size: 0.72rem;
  font-weight: 700;
  color: var(--color-text-tertiary);
}
.cart-spacer {
  height: 9rem;
}
.floating-cart-bar {
  position: fixed;
  left: 1.25rem;
  right: 1.25rem;
  bottom: calc(var(--bottom-nav-height) + 0.75rem);
  max-width: calc(var(--app-width) - 2.5rem);
  margin: 0 auto;
  background: var(--color-primary);
  color: #fff;
  border-radius: var(--radius-lg);
  padding: 0.9rem 1.1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  text-decoration: none;
  box-shadow: 0 12px 28px rgba(13, 127, 95, 0.35);
  z-index: 30;
}
.floating-cart-count {
  font-size: 0.72rem;
  font-weight: 700;
  background: rgba(255, 255, 255, 0.2);
  padding: 0.2rem 0.55rem;
  border-radius: var(--radius-full);
}
.floating-cart-label {
  font-weight: 700;
  font-size: 0.88rem;
}
.floating-cart-total {
  font-weight: 800;
  font-size: 0.9rem;
}
</style>
