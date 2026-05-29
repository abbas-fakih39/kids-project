<template>
  <div class="card">
    <h2>Nos Produits</h2>
    <div v-if="pending">Chargement...</div>
    <div v-else>
      <div v-for="p in products" :key="p.products_id" class="card" style="border: 1px solid #eee;">
        <h3>{{ p.products_name }} ({{ p.products_category }})</h3>
        <p>Prix : {{ p.products_price_per_day }} € / jour</p>
        <p>En stock : {{ p.products_stock }}</p>
        <NuxtLink :to="`/products/${p.products_id}`" class="btn">Voir détails</NuxtLink>
      </div>
    </div>
  </div>
</template>
<script setup>
const { fetchApi } = useApi()
const { data: products, pending } = useAsyncData('products', () => fetchApi('/products'))
</script>
