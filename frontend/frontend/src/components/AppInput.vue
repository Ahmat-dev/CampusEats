<script setup>
defineProps({
  modelValue: { type: [String, Number], default: '' },
  label: { type: String, default: '' },
  type: { type: String, default: 'text' },
  placeholder: { type: String, default: '' },
  icon: { type: String, default: '' },
  required: { type: Boolean, default: false },
  minlength: { type: [String, Number], default: null },
  autocomplete: { type: String, default: 'off' },
})
defineEmits(['update:modelValue'])
</script>

<template>
  <label class="app-field">
    <span v-if="label" class="app-field-label">{{ label }}</span>
    <span class="app-field-control" :class="{ 'has-icon': icon }">
      <span v-if="icon" class="app-field-icon" aria-hidden="true">{{ icon }}</span>
      <input
        :value="modelValue"
        :type="type"
        :placeholder="placeholder"
        :required="required"
        :minlength="minlength ?? undefined"
        :autocomplete="autocomplete"
        class="app-field-input"
        @input="$emit('update:modelValue', $event.target.value)"
      />
    </span>
  </label>
</template>

<style scoped>
.app-field {
  display: block;
  width: 100%;
}
.app-field-label {
  display: block;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 0.35rem;
}
.app-field-control {
  position: relative;
  display: block;
}
.app-field-icon {
  position: absolute;
  left: 0.9rem;
  top: 50%;
  transform: translateY(-50%);
  font-size: 0.95rem;
  opacity: 0.7;
}
.app-field-input {
  width: 100%;
  padding: 0.8rem 1rem;
  border: 1px solid var(--color-border-strong);
  border-radius: var(--radius-md);
  background: var(--color-surface);
  font-size: 0.9rem;
  color: var(--color-text);
  outline: none;
  transition:
    border-color 0.15s ease,
    box-shadow 0.15s ease;
}
.has-icon .app-field-input {
  padding-left: 2.4rem;
}
.app-field-input::placeholder {
  color: var(--color-text-tertiary);
}
.app-field-input:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-primary-light);
}
</style>
