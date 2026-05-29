<template>
  <NuxtLink :to="`/products/${product.products_id}`" class="product-card">
    <div class="img-wrap">
      <img v-if="imgUrl" :src="imgUrl" :alt="product.products_name" loading="lazy" />
      <div v-else class="img-placeholder">
        <span>{{ product.products_name?.charAt(0) }}</span>
      </div>
      <div class="availability-badge">
        <StatusBadge :status="product.products_stock > 0 ? 'Dispo' : 'Rupture'" />
      </div>
    </div>
    <div class="card-body">
      <span class="cat-label">{{ product.products_category }}</span>
      <h3 class="prod-name">{{ product.products_name }}</h3>
      <div class="card-footer">
        <span class="price">{{ parseFloat(product.products_price_per_day).toFixed(0) }}€<small>/j</small></span>
      </div>
    </div>
  </NuxtLink>
</template>
<script setup>
const props = defineProps({ product: { type: Object, required: true } })
const imgUrl = computed(() => props.product.images?.[0]?.image_url ?? null)
</script>
<style scoped>
.product-card {
  display:block; text-decoration:none; color:inherit;
  background:#fff; border-radius:20px;
  box-shadow:0 4px 20px rgba(60,130,245,0.10);
  overflow:hidden;
  transition:transform 0.2s;
  animation: fadeUp 0.4s ease-out both;
}
.product-card:active { transform:scale(0.97); }
@keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

.img-wrap { position:relative; width:100%; aspect-ratio:1; }
.img-wrap img { width:100%; height:100%; object-fit:cover; }
.img-placeholder {
  width:100%; height:100%;
  background:linear-gradient(135deg,#3C82F5 0%,#1B3A57 100%);
  display:flex; align-items:center; justify-content:center;
  color:#fff; font-size:42px; font-weight:700;
}
.availability-badge { position:absolute; top:8px; right:8px; }

.card-body { padding:10px 12px 12px; }
.cat-label { font-size:10px; font-weight:700; letter-spacing:0.5px; text-transform:uppercase; color:#3C82F5; }
.prod-name {
  font-size:13px; font-weight:700; color:#1B3A57;
  margin:4px 0 10px; line-height:1.3;
  display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
}
.card-footer { display:flex; justify-content:space-between; align-items:center; }
.price { font-size:17px; font-weight:800; color:#3C82F5; }
.price small { font-size:11px; font-weight:500; color:#9CA3AF; }
</style>
