<template>
  <div>Redirection vers les produits...</div>
</template>

<script setup>
definePageMeta({
  middleware: [() => navigateTo('/products')]
})
</script>
