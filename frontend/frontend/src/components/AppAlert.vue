<script setup>
defineProps({
  tone: { type: String, default: 'danger' }, // danger | warning | info
})
</script>

<template>
  <p class="app-alert" :class="`tone-${tone}`"><slot /></p>
</template>

<style scoped>
.app-alert {
  border-radius: var(--radius-md);
  padding: 0.7rem 1rem;
  font-size: 0.8rem;
  margin-bottom: 1rem;
  text-align: left;
  font-weight: 500;
}
.tone-danger {
  background: var(--color-danger-bg);
  color: var(--color-danger);
}
.tone-warning {
  background: var(--color-warning-bg);
  color: var(--color-warning);
}
.tone-info {
  background: var(--color-info-bg);
  color: var(--color-info);
}
</style>
