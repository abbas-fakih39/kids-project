<template>
  <div class="splash">
    <!-- Blurry bg circles -->
    <div class="circle c1"></div>
    <div class="circle c2"></div>
    <div class="circle c3"></div>

    <div class="content" :class="{ visible: mounted }">
      <div class="logo-wrap">
        <div class="logo-icon">
          <svg width="52" height="52" viewBox="0 0 52 52" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="26" cy="26" r="26" fill="#DDE9FE"/>
            <path d="M26 14C19.373 14 14 19.373 14 26s5.373 12 12 12 12-5.373 12-12S32.627 14 26 14zm0 4a3 3 0 110 6 3 3 0 010-6zm0 17c-3.666 0-6.9-1.87-8.82-4.715a.5.5 0 01.419-.785h16.802a.5.5 0 01.419.785C32.9 33.13 29.666 35 26 35z" fill="#3C82F5"/>
          </svg>
        </div>
        <h1 class="brand">Kits &amp; Kids</h1>
        <p class="tag">Location d'équipements bébé pour voyageurs</p>
      </div>

      <div class="actions">
        <button class="btn-primary" @click="navigateTo('/register')">Commencer</button>
        <button class="link-btn" @click="navigateTo('/login')">J'ai déjà un compte</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: false })
const { isAuthenticated } = useAuth()
const mounted = ref(false)

onMounted(() => {
  mounted.value = true
  if (isAuthenticated()) {
    setTimeout(() => navigateTo('/home'), 600)
  }
})
</script>

<style scoped>
.splash {
  min-height: 100svh;
  background: linear-gradient(160deg, #F4F7FA 0%, #DDE9FE 50%, #ffffff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 28px;
  position: relative;
  overflow: hidden;
}

.circle {
  position: absolute;
  border-radius: 50%;
  background: #DDE9FE;
  opacity: 0.5;
  filter: blur(40px);
}
.c1 { width:280px; height:280px; top:-80px; right:-80px; }
.c2 { width:200px; height:200px; bottom:60px; left:-60px; background:#3C82F5; opacity:0.08; }
.c3 { width:160px; height:160px; top:40%; left:60%; }

.content {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  gap: 48px;
  opacity: 0;
  transform: translateY(24px);
  transition: opacity 0.7s ease-out, transform 0.7s ease-out;
}
.content.visible { opacity: 1; transform: translateY(0); }

.logo-wrap { text-align: center; display:flex; flex-direction:column; align-items:center; gap:16px; }
.logo-icon { animation: scaleIn 0.7s cubic-bezier(0.34,1.56,0.64,1) both 0.2s; }
@keyframes scaleIn { from{opacity:0;transform:scale(0.6)} to{opacity:1;transform:scale(1)} }

.brand {
  font-size: 32px;
  font-weight: 800;
  color: #1B3A57;
  letter-spacing: -0.5px;
}
.tag {
  font-size: 15px;
  color: #334155;
  max-width: 240px;
  text-align: center;
  line-height: 1.5;
  animation: fadeUp 0.6s ease-out both 0.4s;
}

.actions {
  display: flex;
  flex-direction: column;
  width: 100%;
  gap: 16px;
  animation: fadeUp 0.6s ease-out both 0.6s;
}
@keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

.link-btn {
  background: none;
  border: none;
  color: #3C82F5;
  font-size: 15px;
  font-weight: 600;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  text-align: center;
  padding: 8px;
}
</style>
