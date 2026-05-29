<template>
  <div class="cart-page">
    <div class="page-header">
      <h1 class="page-header-title">Mon Panier
        <span v-if="cart?.items?.length" class="hdr-badge">{{ cart.items.length }}</span>
      </h1>
    </div>

    <div v-if="pending" class="spinner"></div>

    <div v-else-if="!cart?.items?.length" class="empty-state">
      <div class="empty-icon">🛒</div>
      <h3>Panier vide</h3>
      <p>Parcourez notre catalogue et ajoutez vos équipements.</p>
      <NuxtLink to="/home" class="btn-primary" style="margin-top:24px;text-decoration:none;">Découvrir le catalogue</NuxtLink>
    </div>

    <div v-else class="cart-content">
      <!-- ITEMS -->
      <div class="items-section">
        <div v-for="item in cart.items" :key="item.cart_item_id" class="item-card">
          <div class="item-img">
            <img v-if="item.product?.images?.[0]?.image_url" :src="item.product.images[0].image_url" />
            <div v-else class="item-placeholder">{{ item.product?.products_name?.charAt(0) }}</div>
          </div>
          <div class="item-info">
            <h4>{{ item.product?.products_name }}</h4>
            <p class="item-dates">
              {{ new Date(item.cart_item_start_date).toLocaleDateString('fr-FR',{day:'2-digit',month:'short'}) }}
              → {{ new Date(item.cart_item_end_date).toLocaleDateString('fr-FR',{day:'2-digit',month:'short'}) }}
            </p>
            <p class="item-qty">Qté : {{ item.cart_item_quantity }}</p>
          </div>
          <button class="del-btn" @click="removeItem(item.cart_item_id)">
            <svg width="16" height="16" fill="none" stroke="#EF4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6m4-6v6"/><path d="M9 6V4h6v2"/></svg>
          </button>
        </div>
      </div>

      <!-- DELIVERY -->
      <div class="summary-card">
        <h3 class="sum-title">Mode de livraison</h3>
        <div class="toggle-row">
          <button :class="['tog-btn', { active: delivery === 'retrait_en_magasin' }]" @click="delivery='retrait_en_magasin'">🏪 Retrait</button>
          <button :class="['tog-btn', { active: delivery === 'livraison' }]" @click="delivery='livraison'">🚚 Livraison</button>
        </div>
        <div class="delivery-fields" v-if="delivery==='livraison'">
          <input v-model="addr.street" class="input-field" placeholder="Adresse" />
          <div class="row2">
            <input v-model="addr.zip" class="input-field" placeholder="Code postal" />
            <input v-model="addr.city" class="input-field" placeholder="Ville" />
          </div>
        </div>

        <div class="divider-thin"></div>
        <p v-if="msg" :class="['msg', msgType]">{{ msg }}</p>
        <button class="btn-primary" @click="confirmBooking" :disabled="booking">
          <span v-if="!booking">Confirmer la réservation ✅</span>
          <span v-else class="mini-spin"></span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const { get, post, del } = useApi()
const { data: cart, pending, refresh } = useAsyncData<any>('cart', () => get('/cart'))
const delivery = ref('retrait_en_magasin')
const addr = reactive({ street:'', city:'', zip:'', country:'France' })
const booking = ref(false); const msg = ref(''); const msgType = ref('')

const removeItem = async (id: number) => {
  await del(`/cart/items/${id}`); refresh()
}

const confirmBooking = async () => {
  if (delivery.value === 'livraison' && (!addr.street || !addr.city || !addr.zip)) {
    msg.value = 'Veuillez remplir l\'adresse complète.'; msgType.value = 'err'; return
  }
  booking.value = true; msg.value = ''
  try {
    const items = cart.value.items.map((i: any) => ({ bp_product_id: i.cart_item_product_id, bp_quantity: i.cart_item_quantity }))
    const f = cart.value.items[0]
    await post('/bookings', {
      booking_start_date: f.cart_item_start_date,
      booking_end_date: f.cart_item_end_date,
      booking_delivery_method: delivery.value,
      ...(delivery.value === 'livraison' ? { booking_delivery_street: addr.street, booking_delivery_city: addr.city, booking_delivery_zip: addr.zip, booking_delivery_country: addr.country } : {}),
      items
    })
    await del('/cart')
    msg.value = '🎉 Réservation confirmée !'; msgType.value = 'ok'
    setTimeout(() => navigateTo('/bookings'), 1200)
  } catch(e: any) { msg.value = e.data?.message || 'Erreur.'; msgType.value = 'err' }
  finally { booking.value = false }
}
</script>

<style scoped>
.cart-page { min-height:100svh; background:#F4F7FA; }
.hdr-badge { background:#fff; color:#3C82F5; border-radius:30px; padding:2px 10px; font-size:13px; font-weight:700; margin-left:8px; }
.empty-state { text-align:center; padding:80px 24px; }
.empty-icon { font-size:64px; margin-bottom:16px; }
.empty-state h3 { font-size:20px; font-weight:700; color:#1B3A57; }
.empty-state p { font-size:14px; color:#9CA3AF; margin-top:8px; }
.cart-content { padding:16px; display:flex; flex-direction:column; gap:16px; }
.items-section { display:flex; flex-direction:column; gap:10px; }
.item-card { background:#fff; border-radius:18px; padding:14px; display:flex; gap:12px; align-items:center; box-shadow:0 2px 10px rgba(60,130,245,0.08); }
.item-img { width:68px; height:68px; border-radius:14px; overflow:hidden; flex-shrink:0; background:#DDE9FE; }
.item-img img { width:100%; height:100%; object-fit:cover; }
.item-placeholder { width:100%; height:100%; display:flex; align-items:center; justify-content:center; font-size:24px; font-weight:700; color:#3C82F5; }
.item-info { flex:1; }
.item-info h4 { font-size:14px; font-weight:700; color:#1B3A57; margin-bottom:3px; }
.item-dates { font-size:12px; color:#9CA3AF; margin-bottom:3px; }
.item-qty { font-size:12px; color:#3C82F5; font-weight:600; }
.del-btn { width:36px; height:36px; border:none; background:#FEF2F2; border-radius:10px; cursor:pointer; display:flex; align-items:center; justify-content:center; }
.summary-card { background:#fff; border-radius:20px; padding:20px; box-shadow:0 4px 20px rgba(60,130,245,0.10); }
.sum-title { font-size:16px; font-weight:700; color:#1B3A57; margin-bottom:16px; }
.toggle-row { display:flex; background:#F4F7FA; border-radius:14px; padding:4px; margin-bottom:16px; }
.tog-btn { flex:1; padding:10px; border:none; border-radius:10px; font-weight:600; font-size:13px; cursor:pointer; background:transparent; color:#334155; font-family:'Inter',sans-serif; transition:all 0.2s; }
.tog-btn.active { background:#3C82F5; color:#fff; box-shadow:0 4px 10px rgba(60,130,245,0.3); }
.delivery-fields { display:flex; flex-direction:column; gap:10px; margin-bottom:16px; }
.row2 { display:flex; gap:10px; }
.divider-thin { height:1px; background:#F3F4F6; margin:16px 0; }
.msg { font-size:13px;font-weight:500;padding:10px 14px;border-radius:10px;margin-bottom:12px; }
.ok { background:#F0FDF4;color:#166534; }
.err { background:#FEF2F2;color:#DC2626; }
.mini-spin { display:inline-block;width:18px;height:18px;border:2px solid rgba(255,255,255,0.4);border-top-color:#fff;border-radius:50%;animation:spin .6s linear infinite; }
@keyframes spin { to{transform:rotate(360deg);} }
</style>
