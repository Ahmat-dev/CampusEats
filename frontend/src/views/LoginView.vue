<template>
  <main class="login-screen">
    <div style="font-size: 3.5rem; margin-bottom: 1rem;">🔐</div>
    <h2 style="font-size: 1.5rem; font-weight: 800; color: #059669; margin: 0 0 0.5rem 0;">Student Portal Login</h2>
    <p style="font-size: 0.85rem; color: #6b7280; margin-bottom: 1.5rem;">Access CampusEats pre-orders using your UTM ID</p>

    <input type="text" v-model="email" placeholder="UTM Student Email" class="login-input" />
    <input type="password" v-model="password" placeholder="Password" class="login-input" style="margin-top: 0.75rem;" />

    <button class="btn-login" @click="handleLogin">Secure Login →</button>
  </main>
</template>

<script setup>
import { ref } from 'vue';
import api from '../api';

const emit = defineEmits(['login-success']);

const email = ref('');
const password = ref('');

const handleLogin = async () => {
  if (!email.value || !password.value) {
    alert("Please enter both your UTM email and password.");
    return;
  }

  try {
    const response = await api.post('/api/auth/login', {
      email: email.value,
      password: password.value
    });

    const token = response.data.token;
    localStorage.setItem('jwt_token', token);

    emit('login-success');

  } catch (error) {
    console.error("Login Error:", error);
    alert("Login failed. Check your credentials.");
  }
};
</script>

<style scoped>
.login-screen { flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 2rem; text-align: center; box-sizing: border-box; }
.login-input { width: 100%; padding: 0.75rem 1rem; border: 1px solid #d1d5db; border-radius: 0.75rem; box-sizing: border-box; font-size: 0.875rem; outline: none; }
.btn-login { background: #059669; color: white; width: 100%; border: none; padding: 1rem; border-radius: 0.75rem; font-size: 0.875rem; font-weight: bold; cursor: pointer; margin-top: 1.5rem; box-sizing: border-box; }
</style>
