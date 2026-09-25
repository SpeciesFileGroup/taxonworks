function initialize() {
  const input = document.querySelector('#dashboard .project-filter-input')

  if (!input) return

  const items = [...document.querySelectorAll('#dashboard .project-item')]
  const emptyMessage = document.querySelector('#dashboard .project-filter-empty')

  function visibleItems() {
    return items.filter((item) => !item.classList.contains('d-none'))
  }

  function filterProjects() {
    const lowerSearch = input.value.trim().toLowerCase()

    items.forEach((item) => {
      const name = item.querySelector('a').textContent.toLowerCase()

      item.classList.toggle('d-none', !name.includes(lowerSearch))
    })

    emptyMessage.classList.toggle('d-none', visibleItems().length > 0)
  }

  function openFirstProject(e) {
    if (e.key !== 'Enter') return

    const firstLink = visibleItems()[0]?.querySelector('a')

    if (firstLink) firstLink.click()
  }

  input.removeEventListener('input', filterProjects)
  input.addEventListener('input', filterProjects)
  input.removeEventListener('keydown', openFirstProject)
  input.addEventListener('keydown', openFirstProject)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#dashboard')) {
    initialize()
  }
})
