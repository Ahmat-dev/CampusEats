<template>
  <main class="checkout-screen">
    <h2 class="page-title">Your basket</h2>

    <AppAlert v-if="errorMessage">{{ errorMessage }}</AppAlert>

    <EmptyState v-if="cartStore.items.length === 0" icon="🛒" title="Your basket is empty">
      <template #action>
        <RouterLink to="/vendors"><AppButton variant="outline">Browse vendors</AppButton></RouterLink>
      </template>
    </EmptyState>

    <template v-else>
      <p class="vendor-note">
        Ordering from <strong>{{ cartStore.vendorName }}</strong>
      </p>

      <div class="cart-list">
        <div v-for="item in cartStore.items" :key="item.id" class="cart-row">
          <FoodImage :src="item.image_url" :name="item.name" class="cart-thumb" />
          <div class="cart-row-body">
            <div class="cart-row-name">{{ item.name }}</div>
            <div class="cart-row-price">RM {{ item.price.toFixed(2) }} each</div>
          </div>
          <div class="cart-row-end">
            <QtyStepper size="sm" :qty="item.qty" @increase="cartStore.addToCart(item)" @decrease="cartStore.removeOne(item.id)" />
            <div class="cart-row-total">RM {{ (item.price * item.qty).toFixed(2) }}</div>
          </div>
        </div>
      </div>

      <div class="subtotal-row">
        <span>Subtotal</span>
        <span class="subtotal-value">RM {{ cartStore.cartTotal }}</span>
      </div>

      <div class="pickup-field">
        <span class="field-label">Select a 15-minute pickup window</span>
        <div class="pickup-options">
          <button
            v-for="slot in pickupSlots"
            :key="slot.value"
            type="button"
            class="pickup-option"
            :class="{ active: pickupSlot === slot.value }"
            @click="pickupSlot = slot.value"
          >
            <span>{{ slot.value }}</span>
            <span v-if="slot.peak" class="peak-tag">Peak</span>
          </button>
        </div>
      </div>

      <div class="checkout-spacer" />
      <div class="confirm-bar">
        <AppButton block size="lg" :loading="submitting" @click="confirmOrder">
          Confirm pre-order · RM {{ cartStore.cartTotal }}
        </AppButton>
      </div>
    </template>
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { api, ApiError } from '@/api/client'
import { useCartStore } from '@/stores/cart'
import AppAlert from '@/components/AppAlert.vue'
import AppButton from '@/components/AppButton.vue'
import EmptyState from '@/components/EmptyState.vue'
import FoodImage from '@/components/FoodImage.vue'
import QtyStepper from '@/components/QtyStepper.vue'

const cartStore = useCartStore()
const router = useRouter()

const pickupSlots = [
  { value: '12:30 PM - 12:45 PM', peak: true },
  { value: '12:45 PM - 1:00 PM', peak: false },
  { value: '1:00 PM - 1:15 PM', peak: false },
  { value: '1:15 PM - 1:30 PM', peak: false },
]

const pickupSlot = ref(pickupSlots[0].value)
const submitting = ref(false)
const errorMessage = ref('')

async function confirmOrder() {
  submitting.value = true
  errorMessage.value = ''

  try {
    const order = await api.post(
      '/api/orders',
      {
        vendor_id: cartStore.vendorId,
        pickup_at: pickupSlot.value,
        items: cartStore.items.map((item) => ({ menu_item_id: item.id, qty: item.qty })),
      },
      { auth: true },
    )
    cartStore.clearCart()
    router.push(`/order-success/${order.id}`)
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not place your order.'
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.checkout-screen {
  padding: 1rem 1.25rem 1.5rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}
.page-title {
  font-size: 1.3rem;
  font-weight: 800;
  color: var(--color-text);
  margin: 0 0 1rem 0;
}
.vendor-note {
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  margin: 0 0 0.75rem 0;
}
.vendor-note strong {
  color: var(--color-text);
}
.cart-list {
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}
.cart-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 0.65rem 0.8rem;
}
.cart-thumb {
  width: 2.75rem;
  height: 2.75rem;
  font-size: 1rem;
}
.cart-row-body {
  flex: 1;
  min-width: 0;
}
.cart-row-name {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--color-text);
}
.cart-row-price {
  font-size: 0.72rem;
  color: var(--color-text-secondary);
}
.cart-row-end {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.35rem;
}
.cart-row-total {
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--color-text);
}
.subtotal-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 700;
  font-size: 1rem;
  margin-top: 1rem;
  padding-top: 0.85rem;
  border-top: 1px dashed var(--color-border-strong);
}
.subtotal-value {
  color: var(--color-primary-dark);
}
.pickup-field {
  margin-top: 1.5rem;
}
.field-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.03em;
  margin-bottom: 0.6rem;
}
.pickup-options {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.pickup-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0.9rem;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-strong);
  background: var(--color-surface);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
  cursor: pointer;
  text-align: left;
}
.pickup-option.active {
  border-color: var(--color-primary);
  background: var(--color-primary-light);
  color: var(--color-primary-dark);
}
.peak-tag {
  font-size: 0.65rem;
  font-weight: 700;
  color: var(--color-accent);
  background: var(--color-accent-light);
  padding: 0.1rem 0.5rem;
  border-radius: var(--radius-full);
}
.checkout-spacer {
  height: 9rem;
}
.confirm-bar {
  position: fixed;
  left: 1.25rem;
  right: 1.25rem;
  bottom: calc(var(--bottom-nav-height) + 0.75rem);
  max-width: calc(var(--app-width) - 2.5rem);
  margin: 0 auto;
}
</style>
