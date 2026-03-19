import { createContentLoader } from 'vitepress'

export default createContentLoader('codigos/*/index.md', { // <--- Cambiado a index.md
  includeSrc: false,
  render: false,
  transform(raw) {
    return raw
      .map(({ url, frontmatter }) => ({
        // Reemplazamos /index.html por una barra final / para el link
        url: url.replace('index.html', ''), 
        title: frontmatter.title || 'Programa ABAP',
        description: frontmatter.description || 'Documentación técnica.'
      }))
      .sort((a, b) => a.title.localeCompare(b.title))
  }
})
