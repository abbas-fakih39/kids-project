<template>
  <span :class="['pill-badge', cls]">{{ label }}</span>
</template>
<script setup>
const props = defineProps({ status: { type: String, required: true } })
const s = computed(() => props.status?.toLowerCase() ?? '')
const cls = computed(() => {
  if (s.value.includes('terminee') || s.value.includes('valide') || s.value === 'dispo' || s.value.includes('admin'))
    return 'pill-green'
  if (s.value.includes('cours') || s.value.includes('attente') || s.value.includes('client'))
    return 'pill-blue'
  if (s.value.includes('annul') || s.value === 'rupture')
    return 'pill-red'
  if (s.value.includes('orange') || s.value.includes('warn'))
    return 'pill-orange'
  return 'pill-gray'
})
const label = computed(() => props.status.replace(/_/g,' ').replace(/\b\w/g,l=>l.toUpperCase()))
</script>
