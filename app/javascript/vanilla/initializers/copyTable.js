import { html2tsv } from '../utils'

async function copyTableToClipboard(e) {
  const element = e.target
  const selector = element.getAttribute('data-clipboard-table-selector')
  const offset = element.getAttribute('data-offset')

  try {
    await navigator.clipboard.writeText(html2tsv(selector, { offset }))

    TW.workbench.alert.create('Table copied to clipboard', 'notice')
  } catch (e) {}
}

document.addEventListener('turbolinks:load', (_) => {
  document
    .querySelectorAll('[data-clipboard-table-selector]')
    .forEach((element) => {
      element.removeEventListener('click', copyTableToClipboard)
      element.addEventListener('click', copyTableToClipboard)
    })
})
