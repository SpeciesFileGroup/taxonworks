var TW = TW || {}
TW.layout = TW.layout || {}
TW.layout.header = TW.layout.header || {}

Object.assign(TW.layout.header, {})

function initialize(container) {
  const dropdownBtn = container.querySelector('.header-dropdown-btn')
  const dropdownMenu = container.querySelector('.header-dropdown-menu')

  console.log(dropdownBtn, dropdownMenu)

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
}

document.addEventListener('turbolinks:load', function () {
  const menus = [...document.querySelectorAll('.header-dropdown-menu')]

  if (menus.length) {
    menus.forEach(initialize)
  }
})
