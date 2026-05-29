<template>
  <div class="detail-page">
    <div class="img-hero" :style="imgUrl ? `background-image:url('${imgUrl}')` : ''">
      <div v-if="!imgUrl" class="img-placeholder-big">{{ product?.products_name?.charAt(0) }}</div>
      <div class="hero-overlay"></div>
      <button class="back-btn" @click="router.back()">
        <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
    </div>

    <div v-if="pending" class="spinner" style="margin-top:40px;"></div>
    <div v-else-if="product" class="float-card">
      <div class="top-row">
        <StatusBadge :status="product.products_stock > 0 ? 'Dispo' : 'Rupture'" />
        <span class="cat-lbl">{{ product.products_category }}</span>
      </div>
      <h1 class="prod-title">{{ product.products_name }}</h1>
      <div class="price-row">
        <span class="big-price">{{ parseFloat(product.products_price_per_day).toFixed(2) }}€</span>
        <span class="per-day">/jour</span>
      </div>
      <p class="desc">{{ product.products_description }}</p>
      <div v-if="product.products_safety_standards" class="safety-badge">
        🛡️ {{ product.products_safety_standards }}
      </div>

      <div class="divider"></div>

      <!-- BOOK SECTION -->
      <h2 class="section-h">Choisir vos dates</h2>
      <div class="date-row">
        <div class="date-card">
          <label>Arrivée</label>
          <input type="date" v-model="form.start" class="input-field" />
        </div>
        <div class="date-card">
          <label>Départ</label>
          <input type="date" v-model="form.end" :min="form.start" class="input-field" />
        </div>
      </div>

      <div class="qty-block">
        <span class="qty-label">Quantité</span>
        <div class="qty-ctrl">
          <button class="qty-btn" @click="form.qty > 1 && form.qty--">−</button>
          <span class="qty-num">{{ form.qty }}</span>
          <button class="qty-btn" @click="form.qty < product.products_stock && form.qty++">+</button>
        </div>
      </div>

      <div class="total-card" v-if="totalAmt > 0">
        <span class="total-lbl">Total estimé</span>
        <span class="total-val">{{ totalAmt.toFixed(2) }} €</span>
      </div>

      <p v-if="msg" :class="['msg', msgType]">{{ msg }}</p>
      <button class="btn-primary" @click="addToCart" :disabled="adding || product.products_stock === 0" style="margin-top:16px;">
        <span v-if="!adding">{{ product.products_stock === 0 ? 'En rupture de stock' : 'Ajouter au panier 🛒' }}</span>
        <span v-else class="mini-spin"></span>
      </button>

      <!-- REVIEWS -->
      <template v-if="reviewList.length">
        <div class="divider"></div>
        <h2 class="section-h">Avis clients ({{ reviewList.length }})</h2>
        <div class="review-card" v-for="r in reviewList" :key="(r as any).review_id">
          <div class="r-head">
            <div class="r-avatar">{{ (r as any).review_user_id }}</div>
            <span class="stars">{{ '⭐'.repeat((r as any).review_rating) }}</span>
          </div>
          <p class="r-comment" v-if="(r as any).review_comment">{{ (r as any).review_comment }}</p>
          <p class="r-comment no-comment" v-else>Aucun commentaire.</p>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute(); const router = useRouter()
const { get, post } = useApi()
const { data: product, pending } = useAsyncData<any>('product', () => get(`/products/${route.params.id}`))
const { data: reviews } = useAsyncData('reviews', () => get(`/reviews/product/${route.params.id}`))
const reviewList = computed(() => (reviews.value as any[]) || [])
const imgUrl = computed(() => product.value?.images?.[0]?.image_url ?? null)
const form = reactive({ qty:1, start:'', end:'' })
const adding = ref(false); const msg = ref(''); const msgType = ref('')
const totalAmt = computed(() => {
  if (!form.start || !form.end || !product.value) return 0
  const d = Math.max(1, Math.ceil((new Date(form.end).getTime() - new Date(form.start).getTime()) / 86400000))
  return d * form.qty * parseFloat(product.value.products_price_per_day)
})
const addToCart = async () => {
  adding.value = true; msg.value = ''
  try {
    await post('/cart/items', { cart_item_product_id: parseInt(String(route.params.id)), cart_item_quantity: form.qty, cart_item_start_date: new Date(form.start).toISOString(), cart_item_end_date: new Date(form.end).toISOString() })
    msg.value = '✅ Ajouté au panier !'; msgType.value = 'ok'
    setTimeout(() => router.push('/cart'), 900)
  } catch(e:any) { msg.value = e.data?.message || 'Erreur.'; msgType.value = 'err' }
  finally { adding.value = false }
}
</script>

<style scoped>
.detail-page { background:#F4F7FA; min-height:100svh; }
.img-hero {
  height:260px; background:linear-gradient(135deg,#3C82F5,#1B3A57);
  background-size:cover; background-position:center; position:relative;
}
.img-placeholder-big { height:100%; display:flex; align-items:center; justify-content:center; font-size:80px; font-weight:800; color:#fff; }
.hero-overlay { position:absolute; inset:0; background:linear-gradient(to bottom,rgba(0,0,0,0.2) 0%,transparent 60%); }
.back-btn {
  position:absolute; top:52px; left:20px;
  background:rgba(255,255,255,0.9); backdrop-filter:blur(10px);
  border:none; border-radius:12px; width:38px; height:38px;
  display:flex; align-items:center; justify-content:center; cursor:pointer;
}
.float-card {
  background:#fff; border-radius:28px 28px 0 0; margin-top:-28px; position:relative;
  padding:24px 20px 40px; box-shadow:0 -4px 20px rgba(27,58,87,0.06);
}
.top-row { display:flex; justify-content:space-between; margin-bottom:8px; }
.cat-lbl { font-size:11px; font-weight:700; color:#9CA3AF; text-transform:uppercase; letter-spacing:0.5px; }
.prod-title { font-size:24px; font-weight:800; color:#1B3A57; margin-bottom:8px; }
.price-row { display:flex; align-items:baseline; gap:4px; margin-bottom:12px; }
.big-price { font-size:30px; font-weight:800; color:#3C82F5; }
.per-day { font-size:14px; color:#9CA3AF; }
.desc { font-size:14px; color:#334155; line-height:1.6; margin-bottom:12px; }
.safety-badge { font-size:12px; background:#F0FDF4; color:#166534; border-radius:10px; padding:8px 12px; margin-bottom:4px; }
.divider { height:1px; background:#F3F4F6; margin:20px 0; }
.section-h { font-size:17px; font-weight:700; color:#1B3A57; margin-bottom:16px; }
.date-row { display:flex; gap:12px; margin-bottom:16px; }
.date-card { flex:1; display:flex; flex-direction:column; gap:6px; }
.date-card label { font-size:11px; font-weight:700; color:#9CA3AF; text-transform:uppercase; }
.qty-block { display:flex; justify-content:space-between; align-items:center; background:#F4F7FA; border-radius:16px; padding:14px 20px; margin-bottom:16px; }
.qty-label { font-size:14px; font-weight:600; color:#334155; }
.qty-ctrl { display:flex; align-items:center; gap:16px; }
.qty-btn { width:36px; height:36px; border-radius:50%; border:none; background:#3C82F5; color:#fff; font-size:20px; cursor:pointer; display:flex; align-items:center; justify-content:center; font-weight:700; }
.qty-num { font-size:18px; font-weight:700; color:#1B3A57; min-width:24px; text-align:center; }
.total-card { background:linear-gradient(135deg,#3C82F5,#1B3A57); border-radius:16px; padding:16px 20px; display:flex; justify-content:space-between; align-items:center; margin-bottom:4px; }
.total-lbl { color:rgba(255,255,255,0.8); font-size:13px; }
.total-val { color:#fff; font-size:22px; font-weight:800; }
.review-card { background:#F4F7FA; border-radius:16px; padding:14px; margin-bottom:10px; }
.r-head { display:flex; justify-content:space-between; margin-bottom:6px; }
.r-avatar { width:32px; height:32px; background:#DDE9FE; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; color:#3C82F5; }
.stars { font-size:14px; }
.r-comment { font-size:13px; color:#334155; line-height:1.5; }
.no-comment { color:#9CA3AF; font-style:italic; }
.msg { font-size:13px; font-weight:500; padding:10px 14px; border-radius:10px; margin-top:8px; }
.ok { background:#F0FDF4; color:#166534; }
.err { background:#FEF2F2; color:#DC2626; }
.mini-spin { display:inline-block; width:18px; height:18px; border:2px solid rgba(255,255,255,0.4); border-top-color:#fff; border-radius:50%; animation:spin .6s linear infinite; }
@keyframes spin { to { transform:rotate(360deg); } }
</style>
