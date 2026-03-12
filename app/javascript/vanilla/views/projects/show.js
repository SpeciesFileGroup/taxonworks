function handleClipboardButton() {
  const el = document.getElementById('tokenValue')

  navigator.clipboard.writeText(el.textContent)
  TW.workbench.alert.create('API Token copied to clipboard', 'notice')
}

function initialize() {
  const tableEl = document.getElementById('members-table')
  const trs = [...tableEl.querySelectorAll('tbody tr')]
  const input = document.getElementById('input-search')
  const tokenBtn = document.querySelector('.token-btn')

  function filterTable(e) {
    trs.forEach((tr) => {
      const nameEl = tr.querySelector('td:nth-child(2)')
      const lowerContent = nameEl.textContent.toLowerCase()
      const lowerSearch = e.target.value.toLowerCase()

      if (lowerContent.includes(lowerSearch)) {
        tr.classList.remove('d-none')
      } else {
        tr.classList.add('d-none')
      }
    })
  }

  input.removeEventListener('input', filterTable)
  input.addEventListener('input', filterTable)
  tokenBtn?.removeEventListener('click', handleClipboardButton)
  tokenBtn?.addEventListener('click', handleClipboardButton)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#project-profile')) {
    initialize()
  }
})
