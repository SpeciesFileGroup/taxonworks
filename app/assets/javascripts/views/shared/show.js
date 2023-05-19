var TW = TW || {}
TW.views = TW.views || {}
TW.views.shared = TW.views.shared || {}
TW.views.shared.show = TW.views.shared.show || {}

Object.assign(TW.views.shared.show, {
  init: function () {
    document.querySelector('[view-bottom]')?.addEventListener('click', () => {
      const elements = document.querySelectorAll('[data-view="development"]')

      for (const element of elements) {
        element.classList.toggle('d-block')
      }
    })

    const menuDropElements = document.querySelectorAll('.menu-drop')

    for (const element of menuDropElements) {
      const link = element.querySelector('a')

      if (!link) {
        element.classList.add('disable')
      }
    }

    this.bindShortcut()
  },

  bindShortcut: function () {
    TW.workbench.keyboard.createShortcut(
      'alt+left',
      'Go to previous',
      'Taxon names browse',
      function () {
        const elements = document.querySelectorAll(
          '[data-arrow="back"], [data-button="back"]'
        )

        for (const element of elements) {
          element.click()
        }
      }
    )

    TW.workbench.keyboard.createShortcut(
      'alt+right',
      'Go to next',
      'Taxon names browse',
      function () {
        const elements = document.querySelectorAll(
          '[data-arrow="next"], [data-button="next"]'
        )

        for (const element of elements) {
          element.click()
        }
      }
    )
    TW.workbench.keyboard.createShortcut(
      (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + '+p',
      'Pinboard',
      'Add to pinboard',
      function () {
        const element =
          document.querySelector('.pin-button') ||
          document.querySelector('.unpin-button')
        if (element) {
          element.click()
        }
      }
    )
  }
})

document.addEventListener('turbolinks:load', () => {
  if (
    document.querySelector('#show') ||
    document.querySelector('#browse-view')
  ) {
    TW.views.shared.show.init()
  }
})
