<template>
  <main class="not-found">
    <div class="not-found-icon">🍽️</div>
    <h2 class="not-found-title">Page not found</h2>
    <p class="not-found-text">This page wandered off the menu.</p>
    <RouterLink to="/" class="link-home">Go back home</RouterLink>
  </main>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>

<style scoped>
.not-found {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 2rem;
  box-sizing: border-box;
}
.not-found-icon {
  font-size: 3rem;
}
.not-found-title {
  color: var(--color-text);
  font-size: 1.25rem;
  font-weight: 800;
  margin: 1rem 0 0.35rem;
}
.not-found-text {
  color: var(--color-text-secondary);
  font-size: 0.85rem;
  margin: 0 0 1.25rem;
}
.link-home {
  color: var(--color-primary-dark);
  font-weight: 700;
  font-size: 0.85rem;
  text-decoration: none;
}
</style>
