<script setup>
defineProps({
  modelValue: { type: Boolean, required: true },
})
defineEmits(['update:modelValue'])
</script>

<template>
  <button
    type="button"
    class="toggle"
    :class="{ on: modelValue }"
    role="switch"
    :aria-checked="modelValue"
    @click="$emit('update:modelValue', !modelValue)"
  >
    <span class="toggle-knob" />
  </button>
</template>

<style scoped>
.toggle {
  width: 2.4rem;
  height: 1.4rem;
  border-radius: var(--radius-full);
  background: var(--color-border-strong);
  border: none;
  position: relative;
  cursor: pointer;
  padding: 0.15rem;
  flex-shrink: 0;
  transition: background-color 0.15s ease;
}
.toggle.on {
  background: var(--color-primary);
}
.toggle-knob {
  display: block;
  width: 1.1rem;
  height: 1.1rem;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
  transition: transform 0.15s ease;
}
.toggle.on .toggle-knob {
  transform: translateX(1rem);
}
</style>
