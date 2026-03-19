import { createContentLoader } from 'vitepress'

export default createContentLoader('codigos/*/README.md', {
  includeSrc: false,
  render: false,
  transform(raw) {
    return raw
      .map(({ url, frontmatter }) => {
        // Limpiamos la URL para que apunte a la carpeta, no al README.html
        const cleanUrl = url.replace('README.html', '')
        
        return {
          title: frontmatter.title || url.split('/')[2].replace(/-/g, ' ').toUpperCase(),
          url: cleanUrl,
          description: frontmatter.description || 'Programa ABAP / Objeto de Diccionario'
        }
      })
      .sort((a, b) => a.title.localeCompare(b.title)) // Orden alfabético por título
  }
})
