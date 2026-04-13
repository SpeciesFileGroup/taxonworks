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
  _scrollHandlers: [],
  _resizeHandlers: [],
  _mousetrapBound: false,

  init() {
    const helpAttributes = document.querySelectorAll('[data-help]')

    this.teardown()

    this.createElements()

    this.toggleEvent = this.toggleHelp.bind(this)
    this._backgroundClickHandler = () => {
      this.toggleHelp()
    }

    if (helpAttributes.length) {
      this.glowHelpButton()
    }

    if (!this._mousetrapBound) {
      Mousetrap.bind('alt+shift+/', () => {
        this.toggleHelp()
      })
      this._mousetrapBound = true
    }

    this.handleEvents()
    this.elementBackground.addEventListener(
      'click',
      this._backgroundClickHandler
    )
  },

  teardown() {
    this.removeEvents()

    this._scrollHandlers.forEach((fn) =>
      window.removeEventListener('scroll', fn)
    )
    this._resizeHandlers.forEach((fn) =>
      window.removeEventListener('resize', fn)
    )
    this._scrollHandlers = []
    this._resizeHandlers = []

    if (this.elementBackground && this._backgroundClickHandler) {
      this.elementBackground.removeEventListener(
        'click',
        this._backgroundClickHandler
      )
    }

    this.removeElements()

    document.querySelectorAll('[data-help]').forEach((element) => {
      element.classList.remove('help-tip')
    })

    this.elementLegend = null
    this.elementBackground = null
    this.elementButton = null
  },

  getHeight(element) {
    return parseFloat(getComputedStyle(element, null).height.replace('px', ''))
  },

  getWidth(element) {
    return parseFloat(getComputedStyle(element, null).width.replace('px', ''))
  },

  getOffset(element) {
    const rect = element.getBoundingClientRect()

    return {
      top: rect.top + window.scrollY,
      left: rect.left + window.scrollX
    }
  },

  glowHelpButton() {
    const btn = document.querySelector('.help-button')
    if (btn) {
      btn.classList.add('help-button-present')
    }
  },

  attachMouseEvent(bubbleElement) {
    bubbleElement.addEventListener('mouseenter', (event) => {
      const elementLegend = document.querySelector('.help-legend')
      const element = event.target
      const position = this.getOffset(element)

      this.elementLegend.textContent = ''
      this.elementLegend.style.top = `${
        position.top + this.getHeight(element)
      }px`
      this.elementLegend.style.maxWidth = ''
      this.elementLegend.classList.add('help-legend__active')

      this.elementLegend.innerHTML = element.getAttribute('data-legend')

      const containerLegend = this.getWidth(elementLegend)
      const distanceRight = window.innerWidth - position.left

      if (containerLegend > distanceRight) {
        this.elementLegend.classList.add('tooltip-help-legend-right')
        this.elementLegend.classList.remove('tooltip-help-legend-left')

        this.elementLegend.style.left = ''
        this.elementLegend.style.right =
          distanceRight - this.getWidth(element) + 'px'
        this.elementLegend.style.maxWidth =
          window.innerWidth - distanceRight + 'px'
      } else {
        this.elementLegend.classList.remove('tooltip-help-legend-right')
        this.elementLegend.classList.add('tooltip-help-legend-left')
        this.elementLegend.style.left = position.left + 'px'
        this.elementLegend.style.right = ''
      }

      this.hideAllExcept(element.getAttribute('data-bubble-id'))
    })

    bubbleElement.addEventListener('mouseleave', (event) => {
      const element = event.target

      if (element.classList.contains('help-bubble-tip')) {
        this.elementLegend.textContent = ''
        this.elementLegend.classList.remove('help-legend__active')
        this.elementLegend.style.maxWidth = ''
        this.showAll('.help-bubble-tip')
      }
    })
  },

  createElements() {
    this.elementLegend = document.createElement('div')
    this.elementBackground = document.createElement('div')
    this.elementButton = document.querySelector('.help-button')

    this.elementLegend.classList.add('help-legend')
    this.elementBackground.classList.add('help-background')

    document.body.append(this.elementLegend, this.elementBackground)
  },

  removeElements() {
    const selectors = [
      '.help-bubble-tip',
      '.help-background',
      '.help-legend',
      '.help-button-description'
    ]

    selectors.forEach((selector) => {
      this.removeAllElements(selector)
    })
  },

  addBubbleTips(selector) {
    ;[...document.querySelectorAll(selector)].forEach((el, i) => {
      const bubbleCreated = el.querySelector('.help-bubble-tip')

      if (!bubbleCreated) {
        const bubble = this.makeBubble({ label: i + 1, targetElement: el })

        document.body.append(bubble)
      } else {
        this.attachMouseEvent(bubbleCreated)
      }
    })
  },

  makeBubble({ label, targetElement }) {
    const legend = targetElement.getAttribute('data-help')
    const bubble = document.createElement('div')

    const updateBubblePosition = () => {
      if (!document.body.contains(targetElement)) return

      const { left, top } = this.getOffset(targetElement)

      bubble.style.position = 'absolute'
      bubble.style.top = `${top}px`
      bubble.style.left = `${left}px`
    }

    window.addEventListener('scroll', updateBubblePosition)
    window.addEventListener('resize', updateBubblePosition)
    this._scrollHandlers.push(updateBubblePosition)
    this._resizeHandlers.push(updateBubblePosition)

    updateBubblePosition()

    bubble.setAttribute('data-legend', legend)
    bubble.classList.add('help-bubble-tip')
    bubble.setAttribute('data-bubble-id', label)
    bubble.textContent = label

    this.attachMouseEvent(bubble)

    return bubble
  },

  toggleHelp() {
    if (this.isActive()) {
      this.disableHelp()
    } else {
      this.activateHelp()
    }
  },

  removeAllElements(selector) {
    document.querySelectorAll(selector).forEach((el) => {
      el.remove()
    })
  },

  activateHelp() {
    const helpElements = document.querySelectorAll('[data-help]')

    this.addBubbleTips('[data-help]')

    this.elementBackground.classList.add('help-background__active')
    if (this.elementButton) {
      this.elementButton.classList.add('help-button-active')
    }
    this.elementLegend.textContent = ''

    helpElements.forEach((element) => {
      element.classList.add('help-tip')
    })

    this.showAll('.help-bubble-tip')
  },

  disableHelp() {
    const helpElements = document.querySelectorAll('[data-help]')
    this.elementBackground.classList.remove('help-background__active')
    if (this.elementButton) {
      this.elementButton.classList.remove('help-button-active')
    }
    this.elementLegend.classList.remove('help-legend__active')

    helpElements.forEach((element) => {
      element.classList.remove('help-tip')
    })

    this._scrollHandlers.forEach((fn) =>
      window.removeEventListener('scroll', fn)
    )
    this._resizeHandlers.forEach((fn) =>
      window.removeEventListener('resize', fn)
    )
    this._scrollHandlers = []
    this._resizeHandlers = []

    this.removeAllElements('.help-bubble-tip')
  },

  isActive() {
    return (
      this.elementBackground &&
      this.elementBackground.classList.contains('help-background__active')
    )
  },

  hideAllExcept(value) {
    const bubbleElements = [...document.querySelectorAll('.help-bubble-tip')]

    bubbleElements.forEach((element) => {
      if (element.getAttribute('data-bubble-id') !== value) {
        element.classList.remove('help-bubble-tip__active')
      }
    })
  },

  showAll(className) {
    const bubbleElements = [...document.querySelectorAll(className)]

    bubbleElements.forEach((element) => {
      element.classList.add('help-bubble-tip__active')
    })
  },

  handleEvents() {
    const el = document.querySelector('.help-button')

    el?.addEventListener('click', this.toggleEvent)
  },

  removeEvents() {
    if (this.toggleEvent) {
      const el = document.querySelector('.help-button')

      el.removeEventListener('click', this.toggleEvent)
    }
  }
})

document.addEventListener('turbolinks:load', function () {
  if (document.querySelectorAll('[data-help]').length) {
    TW.workbench.help.init()
  }
})

document.addEventListener('turbolinks:before-cache', function () {
  TW.workbench.help.teardown()
})
