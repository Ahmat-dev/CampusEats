<script setup>
defineProps({
  qty: { type: Number, required: true },
  size: { type: String, default: 'md' },
})
defineEmits(['increase', 'decrease'])
</script>

<template>
  <span class="qty-stepper" :class="`size-${size}`">
    <button type="button" class="qty-btn" aria-label="Remove one" @click="$emit('decrease')">−</button>
    <span class="qty-value">{{ qty }}</span>
    <button type="button" class="qty-btn" aria-label="Add one" @click="$emit('increase')">+</button>
  </span>
</template>

<style scoped>
.qty-stepper {
  display: inline-flex;
  align-items: center;
  background: var(--color-primary-light);
  border-radius: var(--radius-full);
  overflow: hidden;
}
.qty-btn {
  border: none;
  background: transparent;
  color: var(--color-primary-dark);
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  width: 2rem;
  height: 2rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}
.qty-btn:active {
  background: rgba(13, 127, 95, 0.15);
}
.qty-value {
  min-width: 1.4rem;
  text-align: center;
  font-weight: 700;
  font-size: 0.85rem;
  color: var(--color-primary-dark);
}
.size-sm .qty-btn {
  width: 1.65rem;
  height: 1.65rem;
  font-size: 0.9rem;
}
.size-sm .qty-value {
  font-size: 0.78rem;
  min-width: 1.1rem;
}
</style>
