document.addEventListener('turbolinks:load', function () {
  const hubTabs = document.querySelector('#hub_tabs')

  if (hubTabs) {
    const currentTabId = hubTabs.dataset.currentTab
    const currentTab = document.getElementById(currentTabId)

    if (currentTab) {
      currentTab.classList.add('current_hub_category')
    }

    TW.workbench.keyboard.createShortcut(
      'shift+1',
      'Select first tab',
      'Hub',
      function () {
        const firstTab = document.querySelector('#hub_tabs li:nth-child(1) a')
        if (firstTab) firstTab.click()
      }
    )

    TW.workbench.keyboard.createShortcut(
      'shift+2',
      'Select second tab',
      'Hub',
      function () {
        const secondTab = document.querySelector('#hub_tabs li:nth-child(2) a')
        if (secondTab) secondTab.click()
      }
    )

    TW.workbench.keyboard.createShortcut(
      'shift+3',
      'Select third tab',
      'Hub',
      function () {
        const thirdTab = document.querySelector('#hub_tabs li:nth-child(3) a')
        if (thirdTab) thirdTab.click()
      }
    )
  }
})
