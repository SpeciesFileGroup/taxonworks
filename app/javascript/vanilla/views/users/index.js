function initialize() {
  const table = document.querySelector('.list-table')
  const inputs = [...document.querySelectorAll('.list-filter-input')]

  if (!table || !inputs.length) return

  const trs = [...table.querySelectorAll('tbody tr')]

  function filterTable(e) {
    const lowerSearch = e.target.value.toLowerCase()

    // Keep the top and bottom filter inputs in sync.
    inputs.forEach((input) => {
      if (input !== e.target) input.value = e.target.value
    })

    trs.forEach((tr) => {
      const nameEl = tr.querySelector('td:nth-child(2)')
      const lowerContent = nameEl.textContent.toLowerCase()

      tr.classList.toggle('d-none', !lowerContent.includes(lowerSearch))
    })
  }

  inputs.forEach((input) => {
    input.removeEventListener('input', filterTable)
    input.addEventListener('input', filterTable)
  })
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#user-list')) {
    initialize()
  }
})
