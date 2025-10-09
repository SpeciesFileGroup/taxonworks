import DOMPurify from 'dompurify'

export function decodeBasicEntities(str) {
  return str
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, ' ')
}

export function escapeHtml(str) {
  return DOMPurify.sanitize(str, {
    USE_PROFILES: { html: false }
  })
}
