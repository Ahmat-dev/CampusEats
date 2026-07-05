<template>
  <main class="success-screen">
    <template v-if="order">
      <div class="success-icon">🎉</div>
      <h2 class="success-heading">Pre-order confirmed!</h2>
      <p class="success-text">Your order has been sent to the vendor and is holding for pickup.</p>

      <OrderStatusStepper :status="order.status ?? 'placed'" class="success-stepper" />

      <div class="receipt-box">
        <div class="receipt-header">Digital receipt</div>
        <div class="receipt-row"><span>🔢 Order #</span><strong>{{ order.id }}</strong></div>
        <div class="receipt-row">
          <span>⏱️ Pickup window</span>
          <strong class="receipt-highlight">{{ order.pickup_at }}</strong>
        </div>
        <div class="receipt-row"><span>📦 Items</span><strong>{{ order.items.reduce((s, i) => s + i.qty, 0) }}</strong></div>
        <div class="receipt-total">
          <span>Total charged</span>
          <span class="receipt-highlight">RM {{ order.total.toFixed(2) }}</span>
        </div>
      </div>

      <AppButton as="RouterLink" to="/vendors" variant="secondary" size="lg" block>Back to food courts</AppButton>
      <RouterLink to="/orders" class="link-orders">View order history</RouterLink>
    </template>

    <AppAlert v-else-if="errorMessage">{{ errorMessage }}</AppAlert>
    <p v-else class="loading-text">Loading receipt…</p>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { api, ApiError } from '@/api/client'
import AppAlert from '@/components/AppAlert.vue'
import AppButton from '@/components/AppButton.vue'
import OrderStatusStepper from '@/components/OrderStatusStepper.vue'

const route = useRoute()
const order = ref(null)
const errorMessage = ref('')

onMounted(async () => {
  try {
    order.value = await api.get(`/api/orders/${route.params.id}`, { auth: true })
  } catch (e) {
    errorMessage.value = e instanceof ApiError ? e.message : 'Could not load order receipt.'
  }
})
</script>

<style scoped>
.success-screen {
  padding: 2.5rem 1.5rem;
  flex: 1;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-sizing: border-box;
}
.success-icon {
  font-size: 3.5rem;
  margin-bottom: 0.75rem;
}
.success-heading {
  color: var(--color-text);
  font-weight: 800;
  font-size: 1.4rem;
  margin: 0 0 0.4rem 0;
}
.success-text {
  color: var(--color-text-secondary);
  font-size: 0.85rem;
  margin: 0 0 1.75rem 0;
  line-height: 1.5;
  max-width: 280px;
}
.success-stepper {
  width: 100%;
  max-width: 320px;
  margin-bottom: 1.75rem;
}
.receipt-box {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  width: 100%;
  background: var(--color-surface-alt);
  padding: 1.25rem;
  box-sizing: border-box;
  text-align: left;
  margin-bottom: 1.5rem;
}
.receipt-header {
  font-size: 0.72rem;
  color: var(--color-text-secondary);
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  border-bottom: 1px dashed var(--color-border-strong);
  padding-bottom: 0.6rem;
  margin-bottom: 0.75rem;
}
.receipt-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
  margin-bottom: 0.55rem;
  color: var(--color-text-secondary);
}
.receipt-row strong {
  color: var(--color-text);
}
.receipt-highlight {
  color: var(--color-primary-dark) !important;
}
.receipt-total {
  display: flex;
  justify-content: space-between;
  font-weight: 800;
  border-top: 1px solid var(--color-border);
  padding-top: 0.75rem;
  margin-top: 0.6rem;
  font-size: 1.05rem;
}
.link-orders {
  margin-top: 1.1rem;
  font-size: 0.8rem;
  color: var(--color-primary-dark);
  font-weight: 700;
  text-decoration: none;
}
.loading-text {
  color: var(--color-text-tertiary);
  font-size: 0.85rem;
}
</style>
