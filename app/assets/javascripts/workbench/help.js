/*

To active and use:

Add data-help attribute on the elements to make enable the text legend and bubbles on each element.
Example:

<div data-help="This is a test"></div>

*/

var TW = TW || {}
TW.workbench = TW.workbench || {}
TW.workbench.help = TW.workbench.help || {}

Object.assign(TW.workbench.help, {

  init () {
    const helpAttributes = document.querySelectorAll('[data-help]')

    this.removeElements()
    this.createElements()

    if (helpAttributes.length) {
      this.glowHelpButton()
    }

    Mousetrap.bind('alt+shift+/', () => { this.toggleHelp() })
    this.elementButton.addEventListener('click', () => { this.toggleHelp() })
    this.elementBackground.addEventListener('click', () => { this.toggleHelp() })
  },

  getHeight (element) {
    return parseFloat(getComputedStyle(element, null).height.replace('px', ''))
  },

  getWidth (element) {
    return parseFloat(getComputedStyle(element, null).width.replace('px', ''))
  },

  getOffset (element) {
    const rect = element.getBoundingClientRect()

    return {
      top: rect.top + window.scrollY,
      left: rect.left + window.scrollX
    }
  },

  glowHelpButton () {
    document.querySelector('.help-button').classList.add('help-button-present')
  },

  attachMouseEvent (bubbleElement) {
    bubbleElement.addEventListener('mouseenter', event => {
      const elementLegend = document.querySelector('.help-legend')
      const element = event.target
      const position = this.getOffset(element)

      this.elementLegend.textContent = ''
      this.elementLegend.style.top = `${(position.top + this.getHeight(element))}px`
      this.elementLegend.style.maxWidth = ''
      this.elementLegend.classList.add('help-legend__active')

      this.elementLegend.innerHTML = element.parentElement.getAttribute('data-help')

      const containerLegend = this.getWidth(elementLegend)
      const distanceRight = window.innerWidth - position.left

      if (containerLegend > distanceRight) {
        this.elementLegend.classList.add('tooltip-help-legend-right')
        this.elementLegend.classList.remove('tooltip-help-legend-left')

        this.elementLegend.style.left = ''
        this.elementLegend.style.right = distanceRight - this.getWidth(element) + 'px'
        this.elementLegend.style.maxWidth = window.innerWidth - distanceRight + 'px'
      } else {
        this.elementLegend.classList.remove('tooltip-help-legend-right')
        this.elementLegend.classList.add('tooltip-help-legend-left')
        this.elementLegend.style.left = position.left + 'px'
        this.elementLegend.style.right = ''
      }

      this.hideAllExcept(element.getAttribute('data-bubble-id'))
    })

    bubbleElement.addEventListener('mouseleave', event => {
      const element = event.target

      if (element.classList.contains('help-bubble-tip')) {
        this.elementLegend.textContent = ''
        this.elementLegend.classList.remove('help-legend__active')
        this.elementLegend.style.maxWidth = ''
        this.showAll('.help-bubble-tip')
      }
    })
  },

  createElements () {
    this.elementLegend = document.createElement('div')
    this.elementBackground = document.createElement('div')
    this.elementButton = document.createElement('div')
    this.elementDescription = document.createElement('div')

    this.elementLegend.classList.add('help-legend')
    this.elementBackground.classList.add('help-background')
    this.elementButton.classList.add('help-button')
    this.elementDescription.classList.add('help-button-description')
    this.elementDescription.textContent = 'Help'

    this.elementButton.append(this.elementDescription)

    document.body.append(
      this.elementLegend,
      this.elementBackground,
      this.elementButton
    )
  },

  removeElements () {
    const selectors = [
      '.help-bubble-tip',
      '.help-background',
      '.help-button',
      '.help-legend'
    ]

    selectors.forEach(selector => { this.removeAllElements(selector) })
  },

  addBubbleTips (selector) {
    [...document.querySelectorAll(selector)].forEach((el, i) => {
      const bubbleCreated = el.querySelector('.help-bubble-tip')

      if (!bubbleCreated) {
        el.append(this.createBubble(i + 1))
      } else {
        this.attachMouseEvent(bubbleCreated)
      }
    })
  },

  createBubble (index) {
    const bubbleElement = document.createElement('div')

    bubbleElement.classList.add('help-bubble-tip')
    bubbleElement.setAttribute('data-bubble-id', index)
    bubbleElement.textContent = index

    this.attachMouseEvent(bubbleElement)

    return bubbleElement
  },

  toggleHelp () {
    if (this.isActive()) {
      this.disableHelp()
    } else {
      this.activateHelp()
    }
  },

  removeAllElements (selector) {
    const bubbleEements = document.querySelectorAll(selector)

    bubbleEements.forEach(el => { el.remove() })
  },

  activateHelp () {
    const helpElements = document.querySelectorAll('[data-help]')

    this.addBubbleTips('[data-help]')

    this.elementBackground.classList.add('help-background__active')
    this.elementButton.classList.add('help-button-active')
    this.elementLegend.textContent = ''

    helpElements.forEach(element => {
      element.classList.add('help-tip')
    })

    this.showAll('.help-bubble-tip')
  },

  disableHelp () {
    const helpElements = document.querySelectorAll('[data-help]')
    this.elementBackground.classList.remove('help-background__active')
    this.elementButton.classList.remove('help-button-active')
    this.elementLegend.classList.remove('.help-legend__active')

    helpElements.forEach(element => {
      element.classList.remove('help-tip')
    })

    this.removeAllElements('.help-bubble-tip')
  },

  isActive () {
    return this.elementBackground.classList.contains('help-background__active')
  },

  hideAllExcept (value) {
    const bubbleElements = [...document.querySelectorAll('.help-bubble-tip')]

    bubbleElements.forEach(element => {
      if (element.getAttribute('data-bubble-id') !== value) {
        element.classList.remove('help-bubble-tip__active')
      }
    })
  },

  showAll (className) {
    const bubbleElements = [...document.querySelectorAll(className)]

    bubbleElements.forEach(element => {
      element.classList.add('help-bubble-tip__active')
    })
  }
})

document.addEventListener('turbolinks:load', function () {
  if (document.querySelectorAll('[data-help]').length) {
    TW.workbench.help.init()
  }
})
