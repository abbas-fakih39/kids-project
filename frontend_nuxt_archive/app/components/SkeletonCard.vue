<template>
  <div class="skel-card">
    <div class="skel-img shimmer"></div>
    <div class="skel-body">
      <div class="skel-line s1 shimmer"></div>
      <div class="skel-line s2 shimmer"></div>
      <div class="skel-footer">
        <div class="skel-price shimmer"></div>
        <div class="skel-badge shimmer"></div>
      </div>
    </div>
  </div>
</template>
<style scoped>
.skel-card { background:#fff; border-radius:20px; overflow:hidden; box-shadow:0 4px 20px rgba(60,130,245,0.08); }
.skel-img { height:140px; width:100%; }
.skel-body { padding:12px; display:flex; flex-direction:column; gap:8px; }
.skel-line { height:12px; border-radius:6px; }
.s1 { width:80%; }
.s2 { width:55%; }
.skel-footer { display:flex; justify-content:space-between; margin-top:4px; }
.skel-price { height:16px; width:40%; border-radius:6px; }
.skel-badge { height:16px; width:30%; border-radius:30px; }

.shimmer {
  background: linear-gradient(90deg,#f0f0f0 25%,#e0e0e0 50%,#f0f0f0 75%);
  background-size: 300px 100%;
  animation: shimmer 1.3s infinite;
}
@keyframes shimmer {
  from { background-position: -300px 0; }
  to   { background-position:  300px 0; }
}
</style>
