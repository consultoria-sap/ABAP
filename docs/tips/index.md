---
title: "Índice de Tips Técnicos SAP"
description: "Recopilación de trucos, debugging y procesos ABAP"
---

# 📚 Tips Técnicos SAP

Aquí encontrarás notas rápidas sobre debugging, liberación de documentos y herramientas útiles.

<script setup>
import { data as posts } from './tips.data.mjs'
</script>

<div class="tips-grid">
  <div v-for="post in posts" :key="post.url" class="tip-card">
    <a :href="post.url">
      <h3>{{ post.title }}</h3>
      <p v-if="post.description">{{ post.description }}</p>
    </a>
  </div>
</div>

<style scoped>
.tips-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1rem;
  margin-top: 2rem;
}
.tip-card {
  border: 1px solid var(--vp-c-bg-soft);
  background-color: var(--vp-c-bg-soft);
  padding: 1.5rem;
  border-radius: 8px;
  transition: border-color 0.25s;
}
.tip-card:hover {
  border-color: var(--vp-c-brand-1);
}
.tip-card h3 {
  margin: 0;
  color: var(--vp-c-brand-1);
  font-size: 1.1rem;
}
.tip-card p {
  font-size: 0.9rem;
  color: var(--vp-text-2);
  margin-top: 0.5rem;
}
</style>
