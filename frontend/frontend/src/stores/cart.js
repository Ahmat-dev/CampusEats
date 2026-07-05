import { defineStore } from 'pinia'

export const useCartStore = defineStore('cart', {
  state: () => ({
    vendorId: null,
    vendorName: null,
    items: [],
  }),
  getters: {
    totalCount: (state) => state.items.reduce((sum, item) => sum + item.qty, 0),
    cartTotal: (state) => state.items.reduce((sum, item) => sum + item.price * item.qty, 0).toFixed(2),
  },
  actions: {
    // An order can only contain items from one vendor, so switching vendors resets the cart.
    setVendor(vendorId, vendorName) {
      if (this.vendorId !== null && this.vendorId !== vendorId) {
        this.items = []
      }
      this.vendorId = vendorId
      this.vendorName = vendorName
    },
    addToCart(item) {
      const existing = this.items.find((i) => i.id === item.id)
      if (existing) {
        existing.qty++
      } else {
        this.items.push({ ...item, qty: 1 })
      }
    },
    removeOne(itemId) {
      const existing = this.items.find((i) => i.id === itemId)
      if (!existing) return
      existing.qty--
      if (existing.qty <= 0) {
        this.items = this.items.filter((i) => i.id !== itemId)
      }
    },
    clearCart() {
      this.vendorId = null
      this.vendorName = null
      this.items = []
    },
  },
})
