<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  src: { type: String, default: null },
  name: { type: String, default: '' },
  radius: { type: String, default: 'var(--radius-md)' },
  emoji: { type: String, default: '🍴' },
})

const failed = ref(false)
watch(() => props.src, () => (failed.value = false))

const GRADIENTS = [
  'linear-gradient(135deg, #0d7f5f, #16a37a)',
  'linear-gradient(135deg, #c1622d, #e08a4f)',
  'linear-gradient(135deg, #b45309, #d9a441)',
  'linear-gradient(135deg, #1d4ed8, #4f7ff0)',
  'linear-gradient(135deg, #78716c, #a39d95)',
]

function gradientFor(name) {
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return GRADIENTS[Math.abs(hash) % GRADIENTS.length]
}
</script>

<template>
  <div class="food-image" :style="{ borderRadius: radius }">
    <img
      v-if="src && !failed"
      :src="src"
      :alt="name"
      class="food-image-img"
      :style="{ borderRadius: radius }"
      @error="failed = true"
    />
    <div
      v-else
      class="food-image-fallback"
      :style="{ background: gradientFor(name || 'x'), borderRadius: radius }"
    >
      <span>{{ name ? name.charAt(0).toUpperCase() : emoji }}</span>
    </div>
  </div>
</template>

<style scoped>
.food-image {
  overflow: hidden;
  flex-shrink: 0;
}
.food-image-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
.food-image-fallback {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-family: var(--font-heading);
  font-weight: 800;
}
</style>
