import { html2tsv } from '../utils'

async function copyTableToClipboard(e) {
  const selector = e.target.getAttribute('data-clipboard-table-selector')

  try {
    await navigator.clipboard.writeText(html2tsv(selector))

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
