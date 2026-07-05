<script setup>
defineProps({
  options: { type: Array, required: true }, // [{ label, value }]
  modelValue: { type: [String, Number], required: true },
})
defineEmits(['update:modelValue'])
</script>

<template>
  <div class="pill-row scroll-row">
    <button
      v-for="opt in options"
      :key="opt.value"
      type="button"
      class="pill"
      :class="{ active: modelValue === opt.value }"
      @click="$emit('update:modelValue', opt.value)"
    >
      {{ opt.label }}
    </button>
  </div>
</template>

<style scoped>
.pill-row {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.15rem;
}
.pill {
  flex-shrink: 0;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  padding: 0.45rem 1rem;
  border-radius: var(--radius-full);
  font-size: 0.78rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.15s ease;
}
.pill.active {
  background: var(--color-primary);
  color: #fff;
  border-color: var(--color-primary);
}
</style>
