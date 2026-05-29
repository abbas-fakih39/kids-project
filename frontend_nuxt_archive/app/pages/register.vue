<template>
  <div class="auth-page">
    <div class="auth-header">
      <div class="circle1"></div><div class="circle2"></div>
      <div class="logo-small">
        <svg width="32" height="32" viewBox="0 0 52 52" fill="none"><circle cx="26" cy="26" r="26" fill="rgba(255,255,255,0.2)"/><path d="M26 14C19.373 14 14 19.373 14 26s5.373 12 12 12 12-5.373 12-12S32.627 14 26 14zm0 4a3 3 0 110 6 3 3 0 010-6zm0 17c-3.666 0-6.9-1.87-8.82-4.715a.5.5 0 01.419-.785h16.802a.5.5 0 01.419.785C32.9 33.13 29.666 35 26 35z" fill="white"/></svg>
        <span>Kits &amp; Kids</span>
      </div>
      <h1 class="header-title">Créer un compte</h1>
      <p class="header-sub">Rejoignez des milliers de voyageurs</p>
    </div>

    <div class="auth-card">
      <p class="err-box" v-if="error">{{ error }}</p>
      <div class="field-group">
        <div class="row2">
          <div class="field"><span class="fi">👤</span><input type="text" v-model="form.user_prenom" class="input-field" placeholder="Prénom" /></div>
          <div class="field"><span class="fi">👤</span><input type="text" v-model="form.user_nom" class="input-field" placeholder="Nom" /></div>
        </div>
        <div class="field"><span class="fi">✉️</span><input type="email" v-model="form.user_email" class="input-field" placeholder="Email" /></div>
        <div class="field"><span class="fi">🔒</span><input :type="show?'text':'password'" v-model="form.user_password" class="input-field" placeholder="Mot de passe" /></div>
        <div class="field"><span class="fi">🔒</span><input type="password" v-model="confirm" class="input-field" placeholder="Confirmer mot de passe" />
          <button class="toggle-eye" type="button" @click="show=!show">{{ show?'🙈':'👁️' }}</button>
        </div>
      </div>

      <button class="btn-primary mt-24" @click="handleRegister" :disabled="loading">
        <span v-if="!loading">S'inscrire</span>
        <span v-else class="mini-spin"></span>
      </button>
      <p class="alt-link">Déjà un compte ? <NuxtLink to="/login">Se connecter</NuxtLink></p>
    </div>
  </div>
</template>

<script setup lang="ts">
const form = reactive({ user_prenom:'', user_nom:'', user_email:'', user_password:'', user_role:'client' })
const confirm = ref(''); const show = ref(false)
const error = ref(''); const loading = ref(false)
const { post } = useApi(); const { saveTokens } = useAuth()
const handleRegister = async () => {
  if (form.user_password !== confirm.value) { error.value='Les mots de passe ne correspondent pas.'; return }
  loading.value = true; error.value = ''
  try {
    const r: any = await post('/auth/register', form)
    saveTokens(r.accessToken, r.refreshToken); navigateTo('/home')
  } catch (e: any) { error.value = e.data?.message || "Erreur lors de l'inscription." }
  finally { loading.value = false }
}
</script>

<style scoped>
.auth-page { min-height:100svh; display:flex; flex-direction:column; background:#F4F7FA; }
.auth-header { background:linear-gradient(135deg,#1B3A57 0%,#3C82F5 100%); padding:44px 28px 48px; position:relative; overflow:hidden; display:flex; flex-direction:column; align-items:center; gap:8px; }
.circle1,.circle2 { position:absolute; border-radius:50%; opacity:0.12; }
.circle1 { width:180px;height:180px;top:-50px;right:-50px;background:#fff; }
.circle2 { width:140px;height:140px;bottom:-60px;left:-30px;background:#fff; }
.logo-small { position:relative;z-index:1;display:flex;align-items:center;gap:8px;color:#fff;font-size:16px;font-weight:700;margin-bottom:8px; }
.header-title { position:relative;z-index:1;font-size:24px;font-weight:800;color:#fff; }
.header-sub { position:relative;z-index:1;font-size:13px;color:rgba(255,255,255,0.8); }
.auth-card { flex:1;background:#fff;margin:-24px 16px 0;border-radius:28px 28px 0 0;padding:24px;box-shadow:0 -4px 20px rgba(27,58,87,0.08); }
.row2 { display:flex; gap:10px; }
.field-group { display:flex; flex-direction:column; gap:10px; }
.field { position:relative; }
.fi { position:absolute;left:16px;top:50%;transform:translateY(-50%);font-size:16px; }
.input-field { padding-left:46px; }
.toggle-eye { position:absolute;right:16px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;font-size:16px; }
.mt-24 { margin-top:20px; }
.err-box { background:#FEF2F2;border:1px solid #FECACA;border-radius:12px;padding:12px 16px;color:#DC2626;font-size:13px;font-weight:500;margin-bottom:16px; }
.alt-link { text-align:center;margin-top:16px;font-size:14px;color:#334155; }
.alt-link a { color:#3C82F5;font-weight:600;text-decoration:none; }
.mini-spin { display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,0.4);border-top-color:#fff;border-radius:50%;animation:spin .6s linear infinite; }
@keyframes spin { to { transform:rotate(360deg); } }
</style>
