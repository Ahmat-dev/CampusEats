import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

function roleHome(role) {
  if (role === 'vendor') return '/vendor/dashboard'
  if (role === 'admin') return '/admin'
  return '/vendors'
}

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      // No separate landing/welcome screen — visitors land straight in guest
      // browsing (or their own dashboard, if already logged in).
      path: '/',
      redirect: () => roleHome(useAuthStore().role),
    },
    {
      // Login and register are one page (AuthView) with a tab switch between
      // them, rather than two separate screens — sharing the component means
      // Vue Router swaps between them in place instead of full-page navigating.
      path: '/login',
      name: 'login',
      component: () => import('../views/AuthView.vue'),
      meta: { guestOnly: true },
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/AuthView.vue'),
      meta: { guestOnly: true },
    },
    {
      // Public: matches the backend, which doesn't require auth to browse vendors/menus.
      path: '/vendors',
      name: 'vendors',
      component: () => import('../views/VendorListView.vue'),
    },
    {
      path: '/vendors/:id',
      name: 'vendor-menu',
      component: () => import('../views/VendorMenuView.vue'),
    },
    {
      path: '/checkout',
      name: 'checkout',
      component: () => import('../views/CheckoutView.vue'),
      meta: { requiresAuth: true, roles: ['customer'] },
    },
    {
      path: '/order-success/:id',
      name: 'order-success',
      component: () => import('../views/OrderSuccessView.vue'),
      meta: { requiresAuth: true, roles: ['customer'] },
    },
    {
      path: '/orders',
      name: 'orders',
      component: () => import('../views/OrderHistoryView.vue'),
      meta: { requiresAuth: true, roles: ['customer'] },
    },
    {
      path: '/vendor/dashboard',
      name: 'vendor-dashboard',
      component: () => import('../views/VendorManageView.vue'),
      meta: { requiresAuth: true, roles: ['vendor'] },
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('../views/AdminPanelView.vue'),
      meta: { requiresAuth: true, roles: ['admin'] },
    },
    {
      path: '/account',
      name: 'account',
      component: () => import('../views/ProfileView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/notifications',
      name: 'notifications',
      component: () => import('../views/NotificationsView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('../views/NotFoundView.vue'),
    },
  ],
})

router.beforeEach((to) => {
  const auth = useAuthStore()

  if (to.meta.guestOnly && auth.isAuthenticated) {
    return roleHome(auth.role)
  }

  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.meta.roles && !to.meta.roles.includes(auth.role)) {
    return roleHome(auth.role)
  }

  return true
})

export default router
