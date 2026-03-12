function makeInteractiveLogo(logo) {
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

function makeDropdownMenu(container) {
  const dropdownBtn = container.querySelector('.header-dropdown-btn')
  const dropdownMenu = container.querySelector('.header-dropdown-menu')

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

document.addEventListener('turbolinks:load', () => {
  const logo = document.getElementById('taxonworks_logo')
  const menus = [...document.querySelectorAll('.header-dropdown-menu')]

  if (logo) {
    makeInteractiveLogo(logo)
  }

  if (menus.length) {
    menus.forEach(makeDropdownMenu)
  }
})
