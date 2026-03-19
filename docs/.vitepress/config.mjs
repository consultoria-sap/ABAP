import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Tips de SAP ABAP",
  description: "Repositorio libre con códigos para aprender programación SAP",
  base: '/abap/', // IMPORTANTE: Poné el nombre de tu repo entre las barras
  cleanUrls: true, // Quita el .html de las URLs para que queden más modernas
  themeConfig: {
    // Logo y búsqueda rápida (opcional pero recomendado)
    search: {
      provider: 'local'
    },
    nav: [
      { text: 'Inicio', link: '/' },
      { text: 'Tips ABAP', link: '/tips' }
    ],
    sidebar: [
      {
        text: 'Contenido',
        items: [
          { text: 'Introducción', link: '/' },
          { text: 'Programas ABAP', link: '/codigos' },
        ]
      }
    ]

  socialLinks: [
      { icon: 'github', link: 'https://github.com' }
    ],

    footer: {
      message: 'Publicado originalmente en 2017. Migrado a VitePress.',
      copyright: 'Copyright © 2008-presente'
    },

    // Muestra la fecha del último commit de Git en cada página
    lastUpdated: {
      text: 'Actualizado el',
      formatOptions: {
        dateStyle: 'full',
        timeStyle: 'short'
      }
    }
  }
})
