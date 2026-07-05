<script setup>
defineProps({
  status: { type: String, required: true },
})

// Maps every status string used across orders/vendors to a semantic tone.
const TONE = {
  placed: 'warning',
  pending: 'warning',
  preparing: 'info',
  ready: 'success',
  approved: 'success',
  collected: 'neutral',
  cancelled: 'danger',
  rejected: 'danger',
}
</script>

<template>
  <span class="status-badge" :class="`tone-${TONE[status] ?? 'neutral'}`">{{ status }}</span>
</template>

<style scoped>
.status-badge {
  display: inline-flex;
  align-items: center;
  font-size: 0.68rem;
  font-weight: 700;
  padding: 0.28rem 0.7rem;
  border-radius: var(--radius-full);
  text-transform: capitalize;
  letter-spacing: 0.01em;
}
.tone-warning {
  background: var(--color-warning-bg);
  color: var(--color-warning);
}
.tone-info {
  background: var(--color-info-bg);
  color: var(--color-info);
}
.tone-success {
  background: var(--color-success-bg);
  color: var(--color-success);
}
.tone-neutral {
  background: var(--color-neutral-bg);
  color: var(--color-neutral);
}
.tone-danger {
  background: var(--color-danger-bg);
  color: var(--color-danger);
}
</style>
