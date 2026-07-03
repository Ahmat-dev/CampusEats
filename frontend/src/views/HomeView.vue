<template>
  <div class="mobile-container">
    <header v-if="currentScreen !== 'welcome' && currentScreen !== 'login'">
      <div class="brand" @click="returnToVendors">CampusEats</div>
      <div class="cart-pill" v-if="currentScreen === 'menu'" @click="navigateToCheckout">
        🛒 Cart <span class="badge">{{ cartStore.totalCount }}</span>
      </div>
    </header>

    <main v-if="currentScreen === 'welcome'" class="welcome-screen">
      <div class="welcome-logo">🍔</div>
      <h1 class="welcome-heading">Welcome to CampusEats</h1>
      <p class="welcome-text">Skip the long food court lines at UTM. Pre-order your meals and pick them up instantly!</p>
      <button class="btn-start" @click="currentScreen = 'login'">Explore Cafes & Start Order →</button>
      <div class="footer-tag">Group Apex • PR2 Prototype Build</div>
    </main>

    <VendorDashboardView
      v-if="currentScreen === 'vendors'"
      :vendors="vendorsList"
      @select-vendor="selectVendor"
    />

    <VendorMenuView
      v-if="currentScreen === 'menu'"
      :vendor="selectedVendorObj"
      :menuItems="menuItems"
      @go-back="currentScreen = 'vendors'"
      @go-checkout="navigateToCheckout"
    />

    <CheckoutView
      v-if="currentScreen === 'checkout'"
      v-model="selectedSlot"
      @go-back="currentScreen = 'menu'"
      @confirm-order="handleCheckout"
    />

    <LoginView
      v-if="currentScreen === 'login'"
      @login-success="currentScreen = 'vendors'"
    />

    <main v-if="currentScreen === 'success'" class="success-screen">
      <div style="font-size: 4rem; margin-bottom: 1rem;">🎉</div>
      <h2 style="color: #059669; font-weight: 800; font-size: 1.5rem; margin: 0 0 0.5rem 0;">Pre-Order Confirmed!</h2>
      <p style="color: #4b5563; font-size: 0.875rem; margin: 0 0 2rem 0; line-height: 1.4;">
        Your order payload has been structured inside responsive memory containers and is holding for collection setup.
      </p>

      <div class="receipt-box">
        <div class="receipt-header">Digital Receipt Voucher</div>
        <div style="font-size: 0.9rem; margin-bottom: 0.5rem;">🏢 <strong>Counter:</strong> {{ selectedVendorObj?.name }}</div>
        <div style="font-size: 0.9rem; margin-bottom: 0.5rem;">⏱️ <strong>Pickup Window:</strong> <span style="color: #059669; font-weight: bold;">{{ selectedSlot }}</span></div>
        <div style="font-size: 0.9rem; margin-bottom: 0.75rem;">🔢 <strong>Items Packed:</strong> {{ finalSummary.count }} items</div>
        <div class="receipt-total">
          <span>Total Charged:</span>
          <span style="color: #059669;">RM {{ finalSummary.total }}</span>
        </div>
      </div>

      <button class="btn-confirm-dark" @click="resetToDashboard">
        Back to Food Court Dashboard
      </button>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../api';
import { useCartStore } from '../stores/cart';
import VendorDashboardView from './VendorDashboardView.vue';
import VendorMenuView from './VendorMenuView.vue';
import CheckoutView from './CheckoutView.vue';
import LoginView from './LoginView.vue';

const cartStore = useCartStore();
const currentScreen = ref('welcome');
const selectedVendorObj = ref(null);
const vendorsList = ref([]);
const menuItems = ref([]);
const selectedSlot = ref('12:30 PM - 12:45 PM');
const finalSummary = ref({ total: '0.00', count: 0 });

onMounted(async () => {
  try {
    const vendorRes = await api.get('/api/vendors');
    vendorsList.value = vendorRes.data;
  } catch (error) {
    console.error("API Connection Error:", error);
    alert("Cannot connect to the live database.");
  }
});

const selectVendor = async (vendor) => {
  selectedVendorObj.value = vendor;
  cartStore.clearCart();

  try {
    const menuRes = await api.get(`/api/vendors/${vendor.id}/menu-items`);
    menuItems.value = menuRes.data;
    currentScreen.value = 'menu';
  } catch (error) {
    console.error("Menu Fetch Error:", error);
    alert("Failed to load the menu for this vendor.");
  }
};

const navigateToCheckout = () => {
  if (cartStore.totalCount > 0) currentScreen.value = 'checkout';
};

const handleCheckout = async () => {
  try {
    const payload = {
      vendor_id: selectedVendorObj.value.id,
      pickup_at: selectedSlot.value,
      total: cartStore.cartTotal,
      items: cartStore.items.map(item => ({
        menu_item_id: item.id,
        qty: item.qty,
        unit_price: item.price
      }))
    };

    await api.post('/api/orders', payload);

    finalSummary.value = { total: cartStore.cartTotal, count: cartStore.totalCount };
    currentScreen.value = 'success';

  } catch (error) {
    console.error("Order Submission Error:", error);
    alert("Failed to submit the order.");
  }
};

const resetToDashboard = () => {
  cartStore.clearCart();
  currentScreen.value = 'vendors';
};

const returnToVendors = () => {
  if (currentScreen.value !== 'success' && currentScreen.value !== 'welcome') {
    currentScreen.value = 'vendors';
  }
};
</script>

<style>
body { background-color: #f3f4f6; font-family: system-ui, sans-serif; margin: 0; padding: 0; color: #1f2937; }
.mobile-container { max-width: 420px; margin: 0 auto; background: #ffffff; min-height: 100vh; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); display: flex; flex-direction: column; position: relative; }
header { background: #ffffff; padding: 1rem; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 50; border-bottom: 1px solid #e5e7eb; box-sizing: border-box; width: 100%; }
.brand { font-weight: 800; font-size: 1.5rem; color: #059669; cursor: pointer; letter-spacing: -0.025em; }
.cart-pill { background: #ecfdf5; color: #047857; padding: 0.375rem 0.75rem; border-radius: 9999px; font-size: 0.875rem; font-weight: 600; border: 1px solid #d1fae5; display: flex; align-items: center; gap: 0.5rem; cursor: pointer; }
.badge { background: #059669; color: white; border-radius: 9999px; padding: 0.125rem 0.5rem; font-size: 0.75rem; font-weight: bold; }
.welcome-screen { flex: 1; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 2rem; text-align: center; background: linear-gradient(180deg, #ecfdf5 0%, #ffffff 100%); box-sizing: border-box; }
.welcome-logo { font-size: 4.5rem; margin-bottom: 1rem; }
.welcome-heading { font-size: 2.25rem; font-weight: 900; color: #059669; margin: 0 0 0.5rem 0; letter-spacing: -0.03em; }
.welcome-text { font-size: 0.95rem; color: #4b5563; line-height: 1.5; max-width: 280px; margin: 0; }
.btn-start { background: #059669; color: white; width: 100%; border: none; padding: 1.15rem; border-radius: 1rem; font-size: 1rem; font-weight: bold; cursor: pointer; box-shadow: 0 4px 10px rgba(5,150,105,0.3); margin-top: 2rem; box-sizing: border-box; }
.footer-tag { margin-top: auto; font-size: 0.7rem; color: #9ca3af; font-weight: 500; letter-spacing: 0.05em; text-transform: uppercase; }
.success-screen { padding: 2.5rem 1.5rem; flex: 1; text-align: center; display: flex; flex-direction: column; justify-content: center; align-items: center; box-sizing: border-box; }
.receipt-box { border: 1px solid #e5e7eb; border-radius: 1rem; width: 100%; background: #f9fafb; padding: 1.25rem; box-sizing: border-box; text-align: left; margin-bottom: 2rem; }
.receipt-header { font-size: 0.75rem; color: #6b7280; font-weight: bold; text-transform: uppercase; border-bottom: 1px dashed #d1d5db; padding-bottom: 0.5rem; margin-bottom: 0.75rem; }
.receipt-total { display: flex; justify-content: space-between; font-weight: 700; border-top: 1px solid #e5e7eb; padding-top: 0.75rem; margin-top: 0.5rem; font-size: 1.05rem; }
.btn-confirm-dark { background: #1f2937; color: white; width: 100%; border: none; padding: 1rem; border-radius: 0.75rem; font-size: 0.875rem; font-weight: bold; cursor: pointer; text-align: center; box-sizing: border-box; }
</style>
