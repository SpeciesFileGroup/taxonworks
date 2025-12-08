function initialize(logo) {
  const delay = 250
  let clickTimer = null

  function handleClick() {
    if (clickTimer == null) {
      clickTimer = setTimeout(() => {
        window.location.href = '/hub'
        clickTimer = null
      }, delay)
    }
  }

  function handleDoubleClick() {
    clearTimeout(clickTimer)
    clickTimer = null
    window.location.href = '/'
  }

  logo.removeEventListener('click', handleClick)
  logo.removeEventListener('dblclick', handleDoubleClick)
  logo.addEventListener('click', handleClick)
  logo.addEventListener('dblclick', handleDoubleClick)
}

document.addEventListener('turbolinks:load', () => {
  const logo = document.getElementById('taxonworks_logo')

  if (logo) {
    initialize(logo)
  }
})
