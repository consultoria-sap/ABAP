import { createContentLoader } from 'vitepress'

export default createContentLoader('tips/*.md', {
  includeSrc: false, // No necesitamos el cuerpo del texto, solo la info del archivo
  render: false,
  transform(raw) {
    return raw
      .filter(({ url }) => url !== '/tips/') // Excluimos el propio índice
      .map(({ url, frontmatter }) => ({
        title: frontmatter.title || url.split('/').pop().replace('.html', ''),
        url,
        description: frontmatter.description
      }))
      .sort((a, b) => a.title.localeCompare(b.title)) // Orden alfabético
  }
})
