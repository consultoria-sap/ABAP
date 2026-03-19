import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Tips de SAP ABAP",
  description: "Repositorio libre con códigos para aprender programación SAP",
  base: '/abap/', 
  // outDir debe ser relativo a donde se ejecuta el comando
  outDir: './.vitepress/dist',
  cleanUrls: true,
  appearance: 'dark',
  ignoreDeadLinks: true, 
  // ELIMINAMOS srcDir: 'docs' porque ya se lo pasamos por comando
  themeConfig: {
    search: { provider: 'local' },
    nav: [
      { text: 'Inicio', link: '/' },
      { text: 'Tips ABAP', link: '/tips' }
    ],
    sidebar: [
      {
        text: 'Contenido',
        items: [
          { text: 'Introducción', link: '/' },
          { text: 'Códigos ABAP', link: '/codigos/' }, // Agregamos la barra final
        ]
      }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com' }
    ],
    footer: {
      message: 'Publicado originalmente en 2017. Migrado a VitePress.',
      copyright: 'Copyright © 2008-presente'
    }
  }
})
