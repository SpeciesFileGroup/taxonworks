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

export function sanitizeHtml(str) {
  return DOMPurify.sanitize(str, {
    USE_PROFILES: { html: false }
  })
}

export function stripMarkTags(str) {
  if (typeof str !== 'string') return str
  return str.replace(/<\/?mark>/g, '')
}

// Matches a url up to, but not including, punctuation that reads as part of the
// surrounding sentence. Parentheses are consumed only in balanced pairs, so a
// DOI like `10.59893/bjc.24(2).011` and a disambiguating suffix like
// `Curculionidae_(beetle)` both survive, while the `)` closing a url cited in
// parentheses stays outside the link. An unbalanced `(` ends the match rather
// than trailing into the link. Apostrophes are allowed — `Source#url` is free
// text and the href is emitted in double quotes.
const URL_IN_TEXT =
  /\bhttps?:\/\/(?:[^\s<>"()]|\([^\s<>"()]*\))*(?:\([^\s<>"()]*\)|[^\s<>"(.,;:!?)])/gi

// Splits html into tags and the text between them, so text-only replacements
// can never reach into an attribute value.
const TAG_OR_TEXT = /(<[^>]*>)|([^<]+)/g

/**
 * Wraps bare urls in anchors that open in a new tab.
 *
 * Intended for `Source#cached`, which the TaxonWorks CSL style ends with either
 * `https://doi.org/<doi>` or `Available at <url>` (see
 * `lib/vendor/styles/taxonworks.csl`, macro `access`). Markup already present
 * in `cached` — the `<i>` tags TaxonWorks preserves by convention — is left
 * untouched, and urls inside existing tags are never matched.
 *
 * @param {String} html
 * @returns {String} html with bare urls linked
 */
export function linkifyUrls(html) {
  if (typeof html !== 'string') return ''

  return html.replace(TAG_OR_TEXT, (segment, tag, text) => {
    if (tag) return tag

    return text.replace(URL_IN_TEXT, (url) => {
      // `html` is html, so an `&` in a query string arrives as `&amp;`. Decode
      // it before building the href, then re-encode for the attribute, or the
      // link resolves to a url still carrying `&amp;`.
      const href = decodeBasicEntities(url)
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')

      return `<a href="${href}" target="_blank" rel="noopener noreferrer">${url}</a>`
    })
  })
}
