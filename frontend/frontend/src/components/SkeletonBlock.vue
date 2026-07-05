<script setup>
defineProps({
  height: { type: String, default: '1rem' },
  radius: { type: String, default: 'var(--radius-sm)' },
  width: { type: String, default: '100%' },
})
</script>

<template>
  <span
    class="skeleton-block"
    :style="{ height, width, borderRadius: radius }"
  />
</template>

<style scoped>
.skeleton-block {
  display: block;
  background: linear-gradient(
    100deg,
    var(--color-surface-alt) 30%,
    var(--color-border) 50%,
    var(--color-surface-alt) 70%
  );
  background-size: 200% 100%;
  animation: shimmer 1.4s ease-in-out infinite;
}
@keyframes shimmer {
  0% {
    background-position: 150% 0;
  }
  100% {
    background-position: -50% 0;
  }
}
</style>
