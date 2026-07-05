<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, required: true },
})

const STEPS = [
  { value: 'placed', label: 'Placed', icon: '📝' },
  { value: 'preparing', label: 'Preparing', icon: '👨‍🍳' },
  { value: 'ready', label: 'Ready', icon: '🔔' },
  { value: 'collected', label: 'Collected', icon: '📦' },
]

const currentIndex = computed(() => STEPS.findIndex((s) => s.value === props.status))
const isCancelled = computed(() => props.status === 'cancelled' || props.status === 'rejected')
</script>

<template>
  <div v-if="isCancelled" class="stepper-cancelled">This order was cancelled.</div>
  <div v-else class="stepper">
    <div v-for="(step, i) in STEPS" :key="step.value" class="step" :class="{ done: i <= currentIndex }">
      <span class="step-dot">{{ i < currentIndex ? '✓' : step.icon }}</span>
      <span class="step-label">{{ step.label }}</span>
      <span v-if="i < STEPS.length - 1" class="step-line" :class="{ done: i < currentIndex }" />
    </div>
  </div>
</template>

<style scoped>
.stepper {
  display: flex;
  align-items: flex-start;
}
.step {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  text-align: center;
}
.step-dot {
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.9rem;
  z-index: 1;
}
.step.done .step-dot {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: #fff;
}
.step-label {
  font-size: 0.65rem;
  font-weight: 600;
  color: var(--color-text-tertiary);
  margin-top: 0.35rem;
}
.step.done .step-label {
  color: var(--color-primary-dark);
}
.step-line {
  position: absolute;
  top: 1rem;
  left: 50%;
  width: 100%;
  height: 2px;
  background: var(--color-border);
}
.step-line.done {
  background: var(--color-primary);
}
.stepper-cancelled {
  font-size: 0.8rem;
  color: var(--color-danger);
  font-weight: 600;
  background: var(--color-danger-bg);
  padding: 0.6rem 0.85rem;
  border-radius: var(--radius-md);
}
</style>
