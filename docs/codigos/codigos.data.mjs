import { createContentLoader } from 'vitepress'

export default createContentLoader('codigos/*/index.md', {
  transform(raw) {
    return raw
      .map(({ url, frontmatter }) => ({
        // Agregamos /abap y limpiamos el index.html
        url: `/abap${url.replace('index.html', '')}`, 
        title: frontmatter.title || 'Programa ABAP',
        description: frontmatter.description || 'Documentación técnica.'
      }))
      .sort((a, b) => a.title.localeCompare(b.title))
  }
})
