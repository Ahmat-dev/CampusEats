<script setup>
defineProps({
  variant: { type: String, default: 'primary' }, // primary | secondary | outline | ghost | danger
  size: { type: String, default: 'md' }, // md | lg | sm
  block: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  loading: { type: Boolean, default: false },
  as: { type: String, default: 'button' },
})
</script>

<template>
  <component
    :is="as"
    class="app-btn"
    :class="[`variant-${variant}`, `size-${size}`, { block, loading }]"
    :disabled="as === 'button' ? disabled || loading : undefined"
  >
    <span v-if="loading" class="btn-spinner" aria-hidden="true" />
    <slot />
  </component>
</template>

<style scoped>
.app-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  border-radius: var(--radius-md);
  font-weight: 700;
  font-family: var(--font-body);
  cursor: pointer;
  border: 1px solid transparent;
  text-decoration: none;
  white-space: nowrap;
  transition:
    transform 0.15s ease,
    background-color 0.15s ease,
    border-color 0.15s ease,
    opacity 0.15s ease;
}
.app-btn:active:not(:disabled) {
  transform: scale(0.98);
}
.app-btn:disabled,
.app-btn.loading {
  cursor: not-allowed;
  opacity: 0.55;
}
.block {
  width: 100%;
}

.size-sm {
  padding: 0.45rem 0.85rem;
  font-size: 0.78rem;
}
.size-md {
  padding: 0.8rem 1.2rem;
  font-size: 0.9rem;
}
.size-lg {
  padding: 1rem 1.4rem;
  font-size: 0.95rem;
}

.variant-primary {
  background: var(--color-primary);
  color: #fff;
  box-shadow: 0 6px 16px rgba(13, 127, 95, 0.25);
}
.variant-primary:hover:not(:disabled) {
  background: var(--color-primary-dark);
}

.variant-secondary {
  background: var(--color-text);
  color: #fff;
}
.variant-secondary:hover:not(:disabled) {
  background: #000;
}

.variant-outline {
  background: transparent;
  border-color: var(--color-border-strong);
  color: var(--color-text);
}
.variant-outline:hover:not(:disabled) {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.variant-ghost {
  background: var(--color-surface-alt);
  color: var(--color-text-secondary);
}
.variant-ghost:hover:not(:disabled) {
  background: var(--color-border);
}

.variant-danger {
  background: var(--color-danger-bg);
  color: var(--color-danger);
  border-color: #f2d3d3;
}
.variant-danger:hover:not(:disabled) {
  background: #f6d9d9;
}

.btn-spinner {
  width: 0.9em;
  height: 0.9em;
  border-radius: 50%;
  border: 2px solid currentColor;
  border-right-color: transparent;
  animation: spin 0.6s linear infinite;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
