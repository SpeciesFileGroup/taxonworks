function copyToken(e) {
  const token = e.currentTarget.dataset.token

  navigator.clipboard.writeText(token)
  TW.workbench.alert.create('API token copied to clipboard', 'notice')
}

function initialize() {
  const table = document.querySelector('.list-table')
  const input = document.getElementById('input-search')

  if (!table || !input) return

  const trs = [...table.querySelectorAll('tbody tr')]

  function filterTable(e) {
    const lowerSearch = e.target.value.toLowerCase()

    trs.forEach((tr) => {
      const nameEl = tr.querySelector('td:nth-child(2)')
      const lowerContent = nameEl.textContent.toLowerCase()

      tr.classList.toggle('d-none', !lowerContent.includes(lowerSearch))
    })
  }

  input.removeEventListener('input', filterTable)
  input.addEventListener('input', filterTable)

  table.querySelectorAll('.token-copy').forEach((button) => {
    button.removeEventListener('click', copyToken)
    button.addEventListener('click', copyToken)
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#project-list')) {
    initialize()
  }
})
