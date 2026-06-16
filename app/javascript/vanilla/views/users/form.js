function initialize() {
  const table = document.querySelector('#user-new .members-table')
  const input = document.getElementById('user-projects-filter')

  if (!table || !input) return

  const trs = [...table.querySelectorAll('tbody tr')]

  function filterTable(e) {
    const lowerSearch = e.target.value.toLowerCase()

    trs.forEach((tr) => {
      const nameEl = tr.querySelector('td:nth-child(2)')
      const lowerContent = nameEl ? nameEl.textContent.toLowerCase() : ''

      tr.classList.toggle('d-none', !lowerContent.includes(lowerSearch))
    })
  }

  input.removeEventListener('input', filterTable)
  input.addEventListener('input', filterTable)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#user-new')) {
    initialize()
  }
})
