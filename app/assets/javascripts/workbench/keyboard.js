/*
Keyboard shortcuts

Use TW.workbench.keyboard.createShortcut(key, description, section, func) to create a shortcut.

Create:
createShortcut("left", "Move to left", "Lists", function() { do something });

Result:
<span data-shortcut-key="left" data-shortcut-description="Move to left" data-shortcut-section="Lists"></div>

*/

var TW = TW || {}
TW.workbench = TW.workbench || {}
TW.workbench.keyboard = TW.workbench.keyboard || {}

Object.assign(TW.workbench.keyboard, {

  keyCode: ['UP', 'DOWN', 'LEFT', 'RIGHT', 'COMMAND'],
  keyCodeReplace: ['↑', '↓', '←', '→', '⌘'],

  init_keyShortcuts () {
    const keyboardTable = document.querySelector('#keyShortcuts')

    if (keyboardTable) {
      keyboardTable.remove()
    }

    this.keyShortcutElement = this.createTable()
    this.btnClose = this.keyShortcutElement.querySelector('.close')
    this.legendLink = this.keyShortcutElement.querySelector('.legend')
    this.helpBackground = document.querySelector('.help-background')
    this.keyShortcutsPanel = this.keyShortcutElement.querySelector('.panel')

    document.body.append(this.keyShortcutElement)

    this.generalShortcuts()
    this.fillTable()
    this.handleEvents()
  },

  generalShortcuts () {
    const platformKey = (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')

    this.createLegend(`${platformKey}+h`, 'Go to hub', 'General shortcuts', true)
    this.createLegend(`${platformKey}+?`, 'Show/hide help', 'General shortcuts', true)
  },

  createTable () {
    const divContainer = document.createElement('div')

    divContainer.id = 'keyShortcuts'
    divContainer.innerHTML = `
    <a class="legend">Keyboard shortcuts available</a>
      <div class="panel">
        <div class="header">
          <span class="title">Keyboard shortcuts</span>
          <div data-icon="close" class="close small-icon"></div>
        </div>
        <div class="list content">
          <div class="item page-default">
            <table></table>
          </div>
          <div class="item page-shortcuts">
            <table>
            </table>
          </div>
        </div>
      </div>
    </div>`

    return divContainer
  },

  createShortcut (key, description, section, func, isLeft = false) {
    const legendElement = this.createLegendElement(key, description, section, isLeft)

    function customFunction (event) {
      event.preventDefault()
      func(event)
    }

  	Mousetrap.bind(key, customFunction)
    document.body.append(legendElement)
  },

  createLegendElement: (key, description, section, isLeft = false) => {
    const legendElement = document.createElement('span')

    legendElement.style.display = 'hidden'
    legendElement.setAttribute('data-shortcut-key', key)
    legendElement.setAttribute('data-shortcut-description', description)
    legendElement.setAttribute('data-shortcut-section', section)
    legendElement.setAttribute('data-shortcut-left', isLeft)

    return legendElement
  },

  createLegend (key, description, section, isLeft = false) {
    const legendElement = this.createLegendElement(key, description, section, isLeft)

    document.body.append(legendElement)
    if (!this.isShortcutInTable(key)) {
      this.addNewShortcut(legendElement)
    }
  },

  fillTable () {
    document.querySelectorAll('[data-shortcut-key]').forEach(element => {
      const key = element.getAttribute('data-shortcut-key')

      if (!this.isShortcutInTable(key)) {
        TW.workbench.keyboard.addNewShortcut(TW.workbench.keyboard.checkReplaceKeyCode(element))
      }
    })
  },

  checkReplaceKeyCode (element) {
    const shortcut = element.getAttribute('data-shortcut-key').toUpperCase()
    const index = TW.workbench.keyboard.keyCode.findIndex(item => item === shortcut)

    if (index > -1) {
      element.setAttribute('data-shortcut-key', TW.workbench.keyboard.keyCodeReplace[index])
    }
    return element
  },

  createSection (name) {
    const theadElement = document.createElement('thead')
    const tbodyElement = document.createElement('tbody')
    const columnName = document.createElement('th')

    columnName.textContent = name
    tbodyElement.setAttribute('data-shortcut-section', name)

    theadElement.append(document.createElement('th'))
    theadElement.append(columnName)

    return [theadElement, tbodyElement]
  },

  addRowShortcut (shortcutKey, description) {
    const rowElement = document.createElement('tr')
    const shortcutColumn = document.createElement('td')
    const descriptionColumn = document.createElement('td')
    const keyDiv = document.createElement('div')

    keyDiv.classList.add('key')
    keyDiv.setAttribute('data-table-shortcut-key', shortcutKey)
    keyDiv.textContent = shortcutKey
    descriptionColumn.textContent = description

    shortcutColumn.append(keyDiv)
    rowElement.append(shortcutColumn)
    rowElement.append(descriptionColumn)

    return rowElement
  },

  isShortcutInTable (shortcutKey) {
    return document.querySelector(`[data-table-shortcut-key="${shortcutKey}"]`)
  },

  addNewShortcut (element) {
    const sectionName = element.getAttribute('data-shortcut-section')
    const shortcutKey = element.getAttribute('data-shortcut-key')
    const shortcutDescription = element.getAttribute('data-shortcut-description')
    const isLeftTable = element.getAttribute('data-shortcut-left') === 'true'
    const queryString = `.list table tbody[data-shortcut-section="${sectionName}"`
    const tableClass = isLeftTable
      ? '.page-default'
      : '.page-shortcuts'

    let sectionElement = this.keyShortcutElement.querySelector(queryString)

    if (!sectionElement) {
      this.keyShortcutElement.querySelector(`.list ${tableClass} table`).append(...this.createSection(sectionName))
      sectionElement = this.keyShortcutElement.querySelector(queryString)
    }

    sectionElement.append(this.addRowShortcut(shortcutKey, shortcutDescription))
  },

  openViewPanel () {
    this.keyShortcutsPanel.classList.add('active')
  },

  closeViewPanel () {
    this.keyShortcutsPanel.classList.remove('active')
  },

  handleEvents () {
    this.legendLink.addEventListener('click', this.openViewPanel.bind(this))
    this.btnClose.addEventListener('click', this.closeViewPanel.bind(this))
    this.helpBackground.addEventListener('click', this.closeViewPanel.bind(this))
  }
})

document.addEventListener('turbolinks:load', () => {
  TW.workbench.help.init()
  TW.workbench.keyboard.init_keyShortcuts()
})
