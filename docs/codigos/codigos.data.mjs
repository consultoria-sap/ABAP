import { createContentLoader } from 'vitepress'

export default createContentLoader('codigos/*/README.md', {
  includeSrc: false,
  render: false,
  transform(raw) {
    return raw
      .map(({ url, frontmatter }) => ({
        // Reemplazamos /README.html o /README por una barra final /
        url: url.replace(/README(\.html)?$/, ''), 
        title: frontmatter.title || 'Programa sin título',
        description: frontmatter.description || 'Documentación técnica de ABAP.'
      }))
      .sort((a, b) => a.title.localeCompare(b.title))
  }
})
