<template>
  <div class="profile-page">
    <!-- GRADIENT HEADER AVATAR -->
    <div class="prof-header">
      <div class="circle1"></div>
      <div class="avatar-ring">
        <div class="avatar-big">{{ initials }}</div>
      </div>
      <h2 class="full-name">{{ user?.user_prenom }} {{ user?.user_nom }}</h2>
      <p class="email-txt">{{ user?.user_email }}</p>
      <div class="role-pill">
        <span v-if="user?.user_role === 'admin'">⭐ Administrateur</span>
        <span v-else>👤 Client</span>
      </div>
    </div>

    <div v-if="pending" class="spinner"></div>
    <div v-else-if="user" class="content-section">
      <!-- INFOS -->
      <div class="section-card">
        <h3 class="sec-h">Informations personnelles</h3>
        <div class="info-row">
          <div class="info-left"><span class="info-icon">📧</span><div><p class="info-label">Email</p><p class="info-val">{{ user.user_email }}</p></div></div>
        </div>
        <div class="info-row">
          <div class="info-left"><span class="info-icon">📱</span><div><p class="info-label">Téléphone</p><p class="info-val">{{ user.user_number || 'Non renseigné' }}</p></div></div>
        </div>
        <div class="info-row last">
          <div class="info-left"><span class="info-icon">🎂</span><div><p class="info-label">Date de naissance</p><p class="info-val">{{ user.user_birth ? new Date(user.user_birth).toLocaleDateString('fr-FR') : 'Non renseignée' }}</p></div></div>
        </div>
      </div>

      <!-- ACCOUNT LINKS -->
      <div class="section-card">
        <h3 class="sec-h">Mon compte</h3>
        <NuxtLink to="/bookings" class="action-row">
          <div class="ar-left"><span class="ar-icon">📋</span><span>Mes réservations</span></div>
          <span class="chevron">›</span>
        </NuxtLink>
        <div class="action-row">
          <div class="ar-left"><span class="ar-icon">❓</span><span>Aide &amp; Support</span></div>
          <span class="chevron">›</span>
        </div>
      </div>

      <button @click="doLogout" class="logout-btn">🚪 Déconnexion</button>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const { getUser, logout } = useAuth()
const { data: user, pending } = useAsyncData('profile', () => getUser())
const initials = computed(() => {
  if (!user.value) return '?'
  return `${(user.value as any).user_prenom?.[0] ?? ''}${(user.value as any).user_nom?.[0] ?? ''}`.toUpperCase()
})
const doLogout = () => logout()
</script>

<style scoped>
.profile-page { min-height:100svh; background:transparent; }
.prof-header {
  background:linear-gradient(135deg,#1B3A57 0%,#3C82F5 100%);
  padding:52px 24px 44px; text-align:center; position:relative; overflow:hidden;
}
.circle1 { position:absolute;width:250px;height:250px;background:rgba(255,255,255,0.06);border-radius:50%;top:-80px;right:-80px; }
.avatar-ring { width:98px;height:98px;border-radius:50%;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;margin:0 auto 14px;position:relative;z-index:1; }
.avatar-big { width:82px;height:82px;border-radius:50%;background:#fff;color:#3C82F5;font-size:30px;font-weight:800;display:flex;align-items:center;justify-content:center; }
.full-name { font-size:22px;font-weight:800;color:#fff;position:relative;z-index:1; }
.email-txt { font-size:13px;color:rgba(255,255,255,0.75);margin-top:4px;position:relative;z-index:1; }
.role-pill { display:inline-block;background:rgba(255,255,255,0.18);border-radius:30px;padding:5px 14px;color:#fff;font-size:12px;font-weight:600;margin-top:12px;position:relative;z-index:1; }
.content-section { padding: 10px 0 24px; display:flex; flex-direction:column; gap:10px; }
.section-card { background:#fff; border-radius:0; padding:18px 20px; box-shadow:0 2px 10px rgba(60,130,245,0.08); width:100%; }
.sec-h { font-size:16px; font-weight:700; color:#1B3A57; margin-bottom:14px; }
.info-row { display:flex;justify-content:space-between;align-items:center;padding:12px 0;border-bottom:1px solid #F3F4F6; }
.info-row.last { border-bottom:none;padding-bottom:0; }
.info-left { display:flex; align-items:center; gap:12px; }
.info-icon { width:36px;height:36px;background:#F4F7FA;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px; }
.info-label { font-size:11px;color:#9CA3AF;font-weight:500;margin-bottom:2px; }
.info-val { font-size:14px;color:#334155;font-weight:600; }
.action-row { display:flex;justify-content:space-between;align-items:center;padding:14px 0;border-bottom:1px solid #F3F4F6;cursor:pointer;text-decoration:none;color:#334155; }
.action-row:last-child { border-bottom:none;padding-bottom:0; }
.ar-left { display:flex;align-items:center;gap:12px;font-size:14px;font-weight:600;color:#334155; }
.ar-icon { width:36px;height:36px;background:#DDE9FE;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0; }
.chevron { font-size:22px;color:#9CA3AF; }
.logout-btn {
  background:transparent; border:1.5px solid #EF4444; color:#EF4444;
  border-radius:14px; height:52px; width:100%; font-size:15px;font-weight:700;
  cursor:pointer; font-family:'Inter',sans-serif; transition:background 0.2s;
  box-sizing:border-box;
}
.logout-btn:active { background:#FEF2F2; }
</style>
