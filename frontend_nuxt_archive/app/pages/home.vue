<template>
  <div class="home">
    <!-- HEADER -->
    <div class="home-header">
      <div class="circle1"></div>
      <div class="header-content">
        <div class="h-left">
          <div class="avatar">{{ initials }}</div>
          <div>
            <p class="greet">Bonjour {{ user?.user_prenom || '' }} 👋</p>
            <p class="sub">Trouvez l'équipement idéal</p>
          </div>
        </div>
        <div class="bell">🔔</div>
      </div>
      <!-- Search -->
      <div class="search-box">
        <svg class="search-icon" width="18" height="18" fill="none" stroke="#3C82F5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input v-model="q" placeholder="Rechercher un équipement..." class="search-input" />
      </div>
    </div>

    <div class="scroll-content">
      <!-- CATEGORIES -->
      <div class="section">
        <h2 class="sec-title">Catégories</h2>
        <div class="cats-scroll">
          <button v-for="c in CATS" :key="c.key" :class="['chip', { active: cat === c.key }]" @click="cat = c.key">
            <span>{{ c.icon }}</span> {{ c.label }}
          </button>
        </div>
      </div>

      <!-- PRODUCTS -->
      <div class="section">
        <div class="sec-row">
          <h2 class="sec-title">Nos équipements</h2>
          <span class="see-all" @click="cat='Tous'">Voir tout</span>
        </div>

        <div class="products-grid" v-if="!pending">
          <ProductCard v-for="(p, i) in filtered" :key="p.products_id" :product="p" :style="{ animationDelay: i*0.08+'s' }" />
          <div v-if="filtered.length === 0" class="empty-cat">
            <span>🧸</span><p>Aucun produit dans cette catégorie.</p>
          </div>
        </div>

        <div class="products-grid" v-else>
          <SkeletonCard v-for="i in 4" :key="i" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ middleware: 'auth' })
const { getUser } = useAuth()
const { get } = useApi()

const CATS = [
  { key:'Tous', icon:'🧸', label:'Tous' },
  { key:'Poussettes', icon:'🚼', label:'Poussettes' },
  { key:'Voyage', icon:'🚗', label:'Voyage' },
  { key:'Sommeil', icon:'🛏️', label:'Lits' },
  { key:'Repas', icon:'🍼', label:'Repas' },
  { key:'Jouets', icon:'🎮', label:'Jouets' },
]

const user = ref<any>(null)
const q = ref('')
const cat = ref('Tous')
const { data: products, pending } = useAsyncData('products', () => get('/products'))

onMounted(async () => { user.value = await getUser() })

const initials = computed(() => {
  if (!user.value) return '?'
  return `${user.value.user_prenom?.[0] ?? ''}${user.value.user_nom?.[0] ?? ''}`.toUpperCase()
})

const filtered = computed(() => {
  let res: any[] = (products.value as any[]) || []
  if (cat.value !== 'Tous') {
    res = res.filter(p => p.products_category?.toLowerCase().includes(cat.value.toLowerCase().substring(0,4)))
  }
  if (q.value) {
    const s = q.value.toLowerCase()
    res = res.filter(p => p.products_name?.toLowerCase().includes(s))
  }
  return res
})
</script>

<style scoped>
.home { min-height:100svh; background:#F4F7FA; }

.home-header {
  background:linear-gradient(135deg,#1B3A57 0%,#3C82F5 100%);
  padding:52px 24px 70px;
  position:relative; overflow:hidden;
  border-radius:0 0 28px 28px;
}
.circle1 { position:absolute;width:220px;height:220px;background:rgba(255,255,255,0.07);border-radius:50%;top:-60px;right:-60px; }

.header-content { display:flex; justify-content:space-between; align-items:center; position:relative; z-index:1; margin-bottom:24px; }
.h-left { display:flex; align-items:center; gap:12px; }
.avatar { width:44px;height:44px;border-radius:50%;background:#fff;color:#3C82F5;font-weight:800;font-size:16px;display:flex;align-items:center;justify-content:center; }
.greet { font-size:17px;font-weight:700;color:#fff; }
.sub { font-size:12px;color:rgba(255,255,255,0.75);margin-top:2px; }
.bell { width:40px;height:40px;background:rgba(255,255,255,0.15);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:20px; }

.search-box {
  position:relative; z-index:1;
  background:#fff; border-radius:16px; display:flex; align-items:center; gap:12px; padding:0 16px;
  box-shadow:0 8px 24px rgba(27,58,87,0.15);
  margin-bottom:-28px;
}
.search-icon { flex-shrink:0; }
.search-input { flex:1; border:none; outline:none; height:52px; font-size:14px; color:#1B3A57; font-family:'Inter',sans-serif; background:transparent; }

.scroll-content { padding:40px 16px 16px; display:flex; flex-direction:column; gap:20px; }

.section { display:flex; flex-direction:column; gap:12px; }
.sec-row { display:flex; justify-content:space-between; align-items:center; }
.sec-title { font-size:18px; font-weight:700; color:#1B3A57; }
.see-all { font-size:13px; font-weight:600; color:#3C82F5; cursor:pointer; }

.cats-scroll { display:flex; gap:8px; overflow-x:auto; padding-bottom:4px; scrollbar-width:none; }
.cats-scroll::-webkit-scrollbar { display:none; }
.chip {
  flex-shrink:0; padding:8px 16px; border-radius:30px; border:none;
  font-size:13px; font-weight:600; cursor:pointer; display:flex; align-items:center; gap:5px;
  transition:all 0.2s; font-family:'Inter',sans-serif;
  background:#DDE9FE; color:#334155;
}
.chip.active { background:#3C82F5; color:#fff; box-shadow:0 4px 12px rgba(60,130,245,0.35); }

.products-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.empty-cat { grid-column:span 2; text-align:center; padding:40px 0; color:#9CA3AF; }
.empty-cat span { font-size:40px; display:block; margin-bottom:8px; }
</style>
