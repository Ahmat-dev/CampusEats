<script setup>
defineProps({
  icon: { type: String, default: '🍽️' },
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
})
</script>

<template>
  <div class="empty-state">
    <div class="empty-icon">{{ icon }}</div>
    <p class="empty-title">{{ title }}</p>
    <p v-if="subtitle" class="empty-subtitle">{{ subtitle }}</p>
    <div v-if="$slots.action" class="empty-action"><slot name="action" /></div>
  </div>
</template>

<style scoped>
.empty-state {
  text-align: center;
  padding: 3rem 1.5rem;
}
.empty-icon {
  font-size: 2.25rem;
  margin-bottom: 0.75rem;
}
.empty-title {
  font-weight: 700;
  color: var(--color-text);
  font-size: 0.9rem;
}
.empty-subtitle {
  color: var(--color-text-secondary);
  font-size: 0.8rem;
  margin-top: 0.35rem;
}
.empty-action {
  margin-top: 1.25rem;
}
</style>
