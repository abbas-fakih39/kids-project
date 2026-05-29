<template>
  <div class="app-shell">
    <div class="page-wrap">
      <NuxtPage />
    </div>
    <BottomNav v-if="showNav" />
  </div>
</template>

<script setup>
const route = useRoute()
const showNav = computed(() => !['/splash','/login','/register'].includes(route.path))
</script>

<style>
:root {
  --navy:   #1B3A57;
  --dark:   #334155;
  --blue:   #3C82F5;
  --lblue:  #DDE9FE;
  --offwht: #F4F7FA;
  --white:  #FFFFFF;
  --green:  #22C55E;
  --red:    #EF4444;
  --shadow-card: 0 4px 20px rgba(60,130,245,0.10);
  --shadow-btn:  0 4px 15px rgba(60,130,245,0.35);
  --shadow-nav:  0 -4px 20px rgba(27,58,87,0.08);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: linear-gradient(160deg, #C8DCFF 0%, #DDE9FE 30%, #EEF4FF 60%, #f0f5ff 100%);
  background-attachment: fixed;
  display: flex;
  justify-content: center;
  min-height: 100svh;
  color: var(--dark);
  -webkit-font-smoothing: antialiased;
}

.app-shell {
  width: 100%;
  max-width: 430px;
  min-height: 100svh;
  background: linear-gradient(170deg, #EEF4FF 0%, #F4F7FA 40%, #ffffff 100%);
  display: flex;
  flex-direction: column;
  position: relative;
  box-shadow: 0 0 60px rgba(60,130,245,0.12);
}

.page-wrap {
  flex: 1;
  overflow-x: hidden;
  padding-bottom: 80px;
}

/* =========== GLOBAL UTILITY CLASSES =========== */
.btn-primary {
  background: linear-gradient(135deg, #3C82F5 0%, #1B3A57 100%);
  color: #fff;
  border: none;
  border-radius: 14px;
  height: 54px;
  width: 100%;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 0.3px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: var(--shadow-btn);
  transition: transform 0.15s, opacity 0.15s;
  font-family: 'Inter', sans-serif;
}
.btn-primary:active { transform: scale(0.97); opacity: 0.88; }
.btn-primary:disabled { background: #9CA3AF; box-shadow: none; cursor: not-allowed; }

.btn-secondary {
  background: transparent;
  color: var(--blue);
  border: 1.5px solid var(--blue);
  border-radius: 14px;
  height: 54px;
  width: 100%;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  font-family: 'Inter', sans-serif;
  transition: background 0.2s;
}
.btn-secondary:active { background: var(--lblue); }

.input-field {
  width: 100%;
  border-radius: 14px;
  border: 1.5px solid #E2E8F0;
  height: 52px;
  padding: 0 16px;
  font-size: 15px;
  font-family: 'Inter', sans-serif;
  outline: none;
  background: var(--white);
  color: var(--navy);
  transition: border-color 0.2s, box-shadow 0.2s;
}
.input-field:focus {
  border-color: var(--blue);
  box-shadow: 0 0 0 3px rgba(60,130,245,0.15);
}

.page-header {
  background: linear-gradient(135deg, #1B3A57 0%, #3C82F5 100%);
  padding: 52px 24px 20px;
  position: relative;
  overflow: hidden;
}
.page-header::before {
  content: '';
  position: absolute;
  top: -40px; right: -40px;
  width: 160px; height: 160px;
  border-radius: 50%;
  background: rgba(255,255,255,0.07);
}
.page-header::after {
  content: '';
  position: absolute;
  bottom: -60px; left: -30px;
  width: 200px; height: 200px;
  border-radius: 50%;
  background: rgba(255,255,255,0.04);
}
.page-header-title {
  font-size: 22px;
  font-weight: 700;
  color: #fff;
  position: relative;
  z-index: 1;
}
.page-header-sub {
  font-size: 13px;
  color: rgba(255,255,255,0.75);
  margin-top: 2px;
  position: relative;
  z-index: 1;
}

.card {
  background: var(--white);
  border-radius: 20px;
  box-shadow: var(--shadow-card);
}

.pill-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 10px;
  border-radius: 30px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.3px;
  text-transform: uppercase;
}
.pill-blue  { background: var(--lblue); color: var(--blue); }
.pill-green { background: #DCFCE7; color: #15803D; }
.pill-red   { background: #FEE2E2; color: #DC2626; }
.pill-gray  { background: #F3F4F6; color: #6B7280; }
.pill-orange{ background: #FEF3C7; color: #D97706; }

.spinner {
  width: 28px; height: 28px;
  border: 3px solid rgba(60,130,245,0.2);
  border-top-color: var(--blue);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 40px auto;
}
@keyframes spin { to { transform: rotate(360deg); } }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes shimmer {
  from { background-position: -300px 0; }
  to   { background-position: 300px 0; }
}

.anim-fadein { animation: fadeUp 0.35s ease-out both; }
</style>
