<template>
  <nav class="bottom-nav">
    <NuxtLink to="/home" class="nav-item" :class="{ active: isHome }">
      <div class="icon-pill">
        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
      </div>
      <span>Accueil</span>
    </NuxtLink>

    <NuxtLink to="/cart" class="nav-item" active-class="active">
      <div class="icon-pill cart-wrap">
        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
      </div>
      <span>Panier</span>
    </NuxtLink>

    <NuxtLink to="/bookings" class="nav-item" active-class="active">
      <div class="icon-pill">
        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
      </div>
      <span>Résas</span>
    </NuxtLink>

    <NuxtLink to="/profile" class="nav-item" active-class="active">
      <div class="icon-pill">
        <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
      </div>
      <span>Profil</span>
    </NuxtLink>
  </nav>
</template>

<script setup>
const route = useRoute()
const isHome = computed(() => route.path === '/home' || route.path.startsWith('/products'))
</script>

<style scoped>
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  max-width: 430px;
  height: 68px;
  background: rgba(255,255,255,0.97);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  display: flex;
  justify-content: space-around;
  align-items: center;
  box-shadow: 0 -4px 20px rgba(27,58,87,0.08);
  z-index: 200;
  border-top: 1px solid rgba(221,233,254,0.8);
  padding-bottom: env(safe-area-inset-bottom, 0px);
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  text-decoration: none;
  color: #9CA3AF;
  flex: 1;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.2px;
  transition: color 0.2s;
}

.nav-item.active { color: #3C82F5; }

.icon-pill {
  width: 44px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 15px;
  transition: background 0.2s, transform 0.2s;
}

.nav-item.active .icon-pill {
  background: #DDE9FE;
  transform: scale(1.0);
  animation: navBounce 0.4s cubic-bezier(0.34,1.56,0.64,1) both;
}

@keyframes navBounce {
  0%   { transform: scale(0.8); }
  60%  { transform: scale(1.2); }
  100% { transform: scale(1.0); }
}

.cart-wrap { position: relative; }
</style>
