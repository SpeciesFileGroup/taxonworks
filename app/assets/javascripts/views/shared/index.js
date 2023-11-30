var TW = TW || {}
TW.views = TW.views || {}
TW.views.shared = TW.views.shared || {}
TW.views.shared.index = TW.views.shared.index || {}

Object.assign(TW.views.shared.index, {
  init: function () {
    const elementNew = document.querySelector('[data-icon="new"]')
    const elementList = document.querySelector('[data-icon="list"]')
    const elementDownload = document.querySelector('[data-icon="download"]')
    const elementBatch = document.querySelector('[data-icon="batch"]')

    TW.workbench.keyboard.createShortcut(
      'shift+alt+n',
      'Create a new record',
      'Data index',
      () => {
        clickOnElement(elementNew)
      }
    )

    TW.workbench.keyboard.createShortcut(
      'shift+alt+l',
      'List records',
      'Data index',
      () => {
        clickOnElement(elementList)
      }
    )

    TW.workbench.keyboard.createShortcut(
      'shift+alt+d',
      'Download records list',
      'Data index',
      () => {
        clickOnElement(elementDownload)
      }
    )

    TW.workbench.keyboard.createShortcut(
      'shift+alt+b',
      'Batch load',
      'Data index',
      () => {
        clickOnElement(elementBatch)
      }
    )

    function clickOnElement(element) {
      if (element) {
        element.click()
      }
    }
  }
})

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('#model_index')) {
    TW.views.shared.index.init()
  }
})
