var TW = TW || {}
TW.layout = TW.layout || {}
TW.layout.header = TW.layout.header || {}

Object.assign(TW.layout.header, {})

document.addEventListener('turbolinks:load', function () {
  const dropdownBtn = document.getElementById('header-dropdown-btn')
  const dropdownMenu = document.getElementById('header-dropdown-menu')

  if (dropdownBtn && dropdownMenu) {
    dropdownBtn.addEventListener('click', function (event) {
      event.stopPropagation()
      dropdownMenu.classList.toggle('show')
    })

    function handleEvent(event) {
      if (!event.target || !dropdownMenu?.contains(event.target)) {
        dropdownMenu.classList.remove('show')
      }
    }

    document.removeEventListener('pointerdown', handleEvent, {
      capture: true
    })
    document.removeEventListener('contextmenu', handleEvent, {
      capture: true
    })

    document.addEventListener('pointerdown', handleEvent, {
      passive: true,
      capture: true
    })
    document.addEventListener('contextmenu', handleEvent, {
      passive: true,
      capture: true
    })
  }
})
