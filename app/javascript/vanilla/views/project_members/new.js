function initialize() {
  const input = document.getElementById('input-search')
  const table = document.querySelector('.members-table')

  function filterTable() {
    const filter = input.value.toLowerCase()
    const rows = table.querySelectorAll('tbody tr')

    rows.forEach((row) => {
      if (row.querySelector('th')) return

      const cells = row.querySelectorAll('td')
      if (cells.length === 0) return

      const nameCell = cells[2]
      const name = nameCell.textContent.toLowerCase()

      if (name.includes(filter)) {
        row.classList.remove('d-none')
      } else {
        row.classList.add('d-none')
      }
    })

    rows.forEach((row, index) => {
      const isHeaderRow = row.querySelector('th')

      if (isHeaderRow) {
        let hasVisibleChild = false

        for (let i = index + 1; i < rows.length; i++) {
          const nextRow = rows[i]
          if (nextRow.querySelector('th')) break

          if (!nextRow.classList.contains('d-none')) {
            hasVisibleChild = true
            break
          }
        }

        if (hasVisibleChild) {
          row.classList.remove('d-none')
        } else {
          row.classList.add('d-none')
        }
      }
    })
  }

  function handleKeydown(e) {
    if (e.key === 'Enter') {
      e.preventDefault()
    }
  }

  input.removeEventListener('keydown', handleKeydown)
  input.removeEventListener('input', filterTable)
  input.addEventListener('keydown', handleKeydown)
  input.addEventListener('input', filterTable)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#project-members-new')) {
    initialize()
  }
})
