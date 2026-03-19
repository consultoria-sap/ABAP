import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Tips de SAP ABAP",
  description: "Repositorio libre con códigos para aprender programación SAP",
  base: '/abap/', // IMPORTANTE: Poné el nombre de tu repo entre las barras
  themeConfig: {
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
  }
})
