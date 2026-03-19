---
title: "Biblioteca de Códigos ABAP"
description: "Programas, Clases y Reportes SAP listos para usar"
---

# 💻 Biblioteca de Códigos

Explora nuestra colección de programas y utilidades desarrolladas para entornos SAP.

<script setup>
import { withBase } from 'vitepress'
import { data as programas } from './codigos.data.mjs'
</script>

<div class="codigos-container">
  <div v-for="prog in programas" :key="prog.url" class="prog-card">
    <a :href="prog.url">
      <div class="card-header">
        <span class="icon">📄</span>
        <h3>{{ prog.title }}</h3>
      </div>
      <p>{{ prog.description }}</p>
      <span class="view-more">Ver código →</span>
    </a>
  </div>
</div>

<style scoped>
.codigos-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
}
.prog-card {
  border: 1px solid var(--vp-c-divider);
  background-color: var(--vp-c-bg-soft);
  padding: 1.5rem;
  border-radius: 12px;
  transition: all 0.3s ease;
  position: relative;
}
.prog-card:hover {
  border-color: var(--vp-c-brand-1);
  transform: translateY(-4px);
  box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}
.card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 0.5rem;
}
.icon { font-size: 1.4rem; }
.prog-card h3 {
  margin: 0;
  font-size: 1.15rem;
  color: var(--vp-c-text-1);
}
.prog-card p {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
  margin-bottom: 1rem;
}
.view-more {
  font-size: 0.85rem;
  color: var(--vp-c-brand-1);
  font-weight: 600;
}
</style>
