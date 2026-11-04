// Run with:
// node --experimental-default-type=module --test spec/javascript/helpers/html.test.mjs

import test from 'node:test'
import assert from 'node:assert/strict'

import { linkifyUrls } from '../../../app/javascript/vue/helpers/html.js'

test('linkifyUrls wraps a DOI url emitted by the taxonworks CSL style', () => {
  assert.equal(
    linkifyUrls('Legalov, A.A. (2024) A new species. https://doi.org/10.59893/bjc.24(2).011'),
    'Legalov, A.A. (2024) A new species. ' +
      '<a href="https://doi.org/10.59893/bjc.24(2).011" target="_blank" rel="noopener noreferrer">' +
      'https://doi.org/10.59893/bjc.24(2).011</a>'
  )
})

test('linkifyUrls preserves the <i> tags TaxonWorks keeps in cached', () => {
  assert.equal(
    linkifyUrls('<i>Sphinxis</i> Roelofs. https://example.org/a'),
    '<i>Sphinxis</i> Roelofs. ' +
      '<a href="https://example.org/a" target="_blank" rel="noopener noreferrer">' +
      'https://example.org/a</a>'
  )
})

test('linkifyUrls decodes entities for href but keeps the displayed text', () => {
  // `cached` is HTML, so a query-string `&` arrives as `&amp;`.
  assert.equal(
    linkifyUrls('Available at https://www.biodiversitylibrary.org/part/1?a=1&amp;b=2'),
    'Available at ' +
      '<a href="https://www.biodiversitylibrary.org/part/1?a=1&amp;b=2" ' +
      'target="_blank" rel="noopener noreferrer">' +
      'https://www.biodiversitylibrary.org/part/1?a=1&amp;b=2</a>'
  )
})

test('linkifyUrls does not match inside an existing attribute', () => {
  const html = '<a href="https://example.org/a">already linked</a>'

  assert.equal(linkifyUrls(html), html)
})

test('linkifyUrls leaves trailing sentence punctuation outside the link', () => {
  assert.equal(
    linkifyUrls('See https://example.org/a.'),
    'See <a href="https://example.org/a" target="_blank" rel="noopener noreferrer">' +
      'https://example.org/a</a>.'
  )
})

test('linkifyUrls keeps balanced parentheses that belong to the url', () => {
  assert.equal(
    linkifyUrls('https://doi.org/10.59893/bjc.24(2).011'),
    '<a href="https://doi.org/10.59893/bjc.24(2).011" target="_blank" rel="noopener noreferrer">' +
      'https://doi.org/10.59893/bjc.24(2).011</a>'
  )
})

test('linkifyUrls keeps a trailing balanced parenthesis inside the link', () => {
  assert.equal(
    linkifyUrls('https://example.org/foo(bar)'),
    '<a href="https://example.org/foo(bar)" target="_blank" rel="noopener noreferrer">' +
      'https://example.org/foo(bar)</a>'
  )
})

test('linkifyUrls leaves a parenthesis that merely wraps the url outside it', () => {
  assert.equal(
    linkifyUrls('see (https://example.org/a) here'),
    'see (<a href="https://example.org/a" target="_blank" rel="noopener noreferrer">' +
      'https://example.org/a</a>) here'
  )
})

test('linkifyUrls returns an empty string when given nothing', () => {
  assert.equal(linkifyUrls(), '')
  assert.equal(linkifyUrls(null), '')
})

test('linkifyUrls leaves text without urls untouched', () => {
  const html = 'Legalov, A.A. (2024) A new species, 235&ndash;238.'

  assert.equal(linkifyUrls(html), html)
})

test('linkifyUrls matches an uppercase scheme', () => {
  assert.equal(
    linkifyUrls('See HTTPS://EXAMPLE.ORG/A'),
    'See <a href="HTTPS://EXAMPLE.ORG/A" target="_blank" rel="noopener noreferrer">' +
      'HTTPS://EXAMPLE.ORG/A</a>'
  )
})

test('linkifyUrls keeps an apostrophe that belongs to the url', () => {
  assert.equal(
    linkifyUrls("https://example.org/O'Brien/x"),
    '<a href="https://example.org/O\'Brien/x" target="_blank" rel="noopener noreferrer">' +
      "https://example.org/O'Brien/x</a>"
  )
})

test('linkifyUrls does not end a link on an unbalanced opening parenthesis', () => {
  assert.equal(
    linkifyUrls('https://example.org/a(b c'),
    '<a href="https://example.org/a" target="_blank" rel="noopener noreferrer">' +
      'https://example.org/a</a>(b c'
  )
})

test('linkifyUrls keeps a trailing parenthesis that disambiguates the url', () => {
  assert.equal(
    linkifyUrls('https://en.wikipedia.org/wiki/Curculionidae_(beetle)'),
    '<a href="https://en.wikipedia.org/wiki/Curculionidae_(beetle)" ' +
      'target="_blank" rel="noopener noreferrer">' +
      'https://en.wikipedia.org/wiki/Curculionidae_(beetle)</a>'
  )
})

test('linkifyUrls re-encodes < and > in the href of a SICI DOI', () => {
  // Wiley SICI DOIs carry angle brackets, which reach `cached` as entities.
  const doi =
    'https://doi.org/10.1002/(SICI)1097-0258(19980815)17:15' +
    '&lt;1623::AID-SIM969&gt;3.0.CO;2-S'

  assert.equal(
    linkifyUrls(doi),
    `<a href="${doi}" target="_blank" rel="noopener noreferrer">${doi}</a>`
  )
})
