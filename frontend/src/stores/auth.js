import { defineStore } from 'pinia'
import { api } from '@/api/client'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('campuseats_token') || null,
    user: JSON.parse(localStorage.getItem('campuseats_user') || 'null'),
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
    role: (state) => state.user?.role ?? null,
  },
  actions: {
    persist(token, user) {
      this.token = token
      this.user = user
      localStorage.setItem('campuseats_token', token)
      localStorage.setItem('campuseats_user', JSON.stringify(user))
    },
    async login(email, password) {
      const { token, user } = await api.post('/api/auth/login', { email, password })
      this.persist(token, user)
      return user
    },
    async register(name, email, password, role) {
      const { token, user } = await api.post('/api/auth/register', { name, email, password, role })
      this.persist(token, user)
      return user
    },
    logout() {
      this.token = null
      this.user = null
      localStorage.removeItem('campuseats_token')
      localStorage.removeItem('campuseats_user')
    },
  },
})
