<template>
  <div class="bookings-page">
    <div class="page-header">
      <h1 class="page-header-title">Mes Réservations</h1>
      <p class="page-header-sub">Gérez vos locations en cours</p>
    </div>

    <!-- PILL TABS -->
    <div class="tabs-wrap">
      <div class="tabs-pill">
        <button v-for="t in TABS" :key="t.key" :class="['tab', { active: active===t.key }]" @click="active=t.key">
          {{ t.label }}
        </button>
      </div>
    </div>

    <div v-if="pending" class="spinner"></div>

    <div v-else-if="!filtered.length" class="empty-state">
      <svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="40" cy="40" r="40" fill="#DDE9FE"/>
        <path d="M20 30h40v30a4 4 0 0 1-4 4H24a4 4 0 0 1-4-4V30z" fill="#3C82F5" opacity=".3"/>
        <rect x="28" y="20" width="6" height="12" rx="3" fill="#3C82F5"/>
        <rect x="46" y="20" width="6" height="12" rx="3" fill="#3C82F5"/>
        <path d="M20 34h40" stroke="#3C82F5" stroke-width="2"/>
      </svg>
      <h3>Aucune réservation</h3>
      <p>Vous n'avez pas de réservation {{ active === 'en_cours' ? 'en cours' : active==='terminee' ? 'terminée' : 'annulée' }}.</p>
    </div>

    <div v-else class="list">
      <div v-for="b in filtered" :key="b.booking_id" class="booking-card" :style="`border-left-color: ${statusColor(b.booking_status)}`">
        <div class="bk-top">
          <div class="bk-dates">
            <svg width="14" height="14" fill="none" stroke="#9CA3AF" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            {{ fmtDate(b.booking_start_date) }} → {{ fmtDate(b.booking_end_date) }}
          </div>
          <StatusBadge :status="b.booking_status" />
        </div>
        <div class="bk-mid">
          <div class="bk-info"><span class="bk-label">Référence</span><span class="bk-val">#{{ b.booking_id }}</span></div>
          <div class="bk-info"><span class="bk-label">Produits</span><span class="bk-val">{{ b.products?.length ?? 0 }} article(s)</span></div>
          <div class="bk-info"><span class="bk-label">Livraison</span><span class="bk-val">{{ b.booking_delivery_method?.replace(/_/g,' ') }}</span></div>
        </div>
        <div class="bk-footer">
          <span class="bk-total-lbl">Total</span>
          <span class="bk-total">{{ parseFloat(b.booking_total_amount).toFixed(2) }} €</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const { get } = useApi()
const active = ref('en_cours')
const TABS = [
  { key:'en_cours', label:'En cours' },
  { key:'terminee', label:'Terminées' },
  { key:'annulee',  label:'Annulées' }
]
const { data: bookings, pending } = useAsyncData('bookings', () => get('/bookings/mine'))
const filtered = computed(() => {
  if (!bookings.value) return []
  return (bookings.value as any[]).filter(b => {
    if (active.value === 'en_cours') return b.booking_status === 'en_cours' || b.booking_status === 'en_attente'
    return b.booking_status === active.value
  })
})
const fmtDate = (d: string) => new Date(d).toLocaleDateString('fr-FR',{day:'2-digit',month:'short'})
const statusColor = (s: string) => {
  if (s==='terminee') return '#22C55E'
  if (s==='annulee') return '#EF4444'
  return '#3C82F5'
}
</script>

<style scoped>
.bookings-page { min-height:100svh; background:#F4F7FA; }
.tabs-wrap { padding:16px 16px 0; }
.tabs-pill { background:#fff; border-radius:16px; display:flex; padding:4px; box-shadow:0 2px 12px rgba(60,130,245,0.08); }
.tab { flex:1; padding:10px 0; border:none; border-radius:12px; font-size:13px; font-weight:600; cursor:pointer; background:transparent; color:#334155; font-family:'Inter',sans-serif; transition:all 0.2s; }
.tab.active { background:#3C82F5; color:#fff; box-shadow:0 4px 12px rgba(60,130,245,0.35); }
.empty-state { text-align:center; padding:60px 32px; display:flex; flex-direction:column; align-items:center; gap:12px; }
.empty-state h3 { font-size:18px; font-weight:700; color:#1B3A57; }
.empty-state p { font-size:14px; color:#9CA3AF; }
.list { padding:14px 16px; display:flex; flex-direction:column; gap:12px; }
.booking-card {
  background:#fff; border-radius:18px; overflow:hidden;
  border-left:4px solid #3C82F5;
  box-shadow:0 4px 16px rgba(60,130,245,0.09);
  animation:fadeUp 0.35s ease-out both;
}
@keyframes fadeUp { from{opacity:0;transform:translateY(12px)} to{opacity:1;transform:translateY(0)} }
.bk-top { display:flex; justify-content:space-between; align-items:center; padding:14px 16px 10px; border-bottom:1px solid #F3F4F6; }
.bk-dates { display:flex; gap:6px; align-items:center; font-size:13px; color:#334155; font-weight:500; }
.bk-mid { padding:12px 16px; display:flex; flex-direction:column; gap:7px; }
.bk-info { display:flex; justify-content:space-between; font-size:13px; }
.bk-label { color:#9CA3AF; }
.bk-val { color:#334155; font-weight:600; }
.bk-footer { padding:12px 16px; background:#F4F7FA; display:flex; justify-content:space-between; align-items:center; }
.bk-total-lbl { font-size:13px; font-weight:600; color:#9CA3AF; }
.bk-total { font-size:20px; font-weight:800; color:#3C82F5; }
</style>
