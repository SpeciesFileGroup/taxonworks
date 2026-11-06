import { sortTableByHeader } from '../utils'

const HEADER_SELECTOR = 'table.tablesorter > thead th'
const INTERACTIVE_SELECTOR = 'a, button, input, select, textarea, label'

function getSortableHeader(event) {
  if (event.target.closest(INTERACTIVE_SELECTOR)) return null

  return event.target.closest(HEADER_SELECTOR)
}

document.addEventListener('click', (event) => {
  const th = getSortableHeader(event)

  if (th) sortTableByHeader(th)
})

document.addEventListener('keydown', (event) => {
  if (event.key !== 'Enter') return

  const th = getSortableHeader(event)

  if (th) {
    event.preventDefault()
    sortTableByHeader(th)
  }
})

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll(HEADER_SELECTOR).forEach((th) => {
    th.tabIndex = 0
  })
})
