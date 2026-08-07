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
  _bubbles: [],
  _repositionHandler: null,
  _repositionRafId: null,

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

    this.handleEvents()
    this.elementBackground.addEventListener(
      'click',
      this._backgroundClickHandler
    )
  },

  teardown() {
    this.removeEvents()
    this.removeRepositionListeners()

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
      const element = event.target
      const position = this.getOffset(element)

      this.elementLegend.textContent = ''
      this.elementLegend.style.top = `${
        position.top + this.getHeight(element)
      }px`
      this.elementLegend.style.maxWidth = ''
      this.elementLegend.classList.add('help-legend__active')

      this.elementLegend.innerHTML = element.getAttribute('data-legend')

      const containerLegend = this.getWidth(this.elementLegend)
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

    bubbleElement.addEventListener('mouseleave', () => {
      this.elementLegend.textContent = ''
      this.elementLegend.classList.remove('help-legend__active')
      this.elementLegend.style.maxWidth = ''
      this.showAll('.help-bubble-tip')
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
      const bubble = this.makeBubble({ label: i + 1, targetElement: el })

      document.body.append(bubble)
    })

    this.addRepositionListeners()
    this.repositionBubbles()
  },

  makeBubble({ label, targetElement }) {
    const legend = targetElement.getAttribute('data-help')
    const bubble = document.createElement('div')

    bubble.style.position = 'absolute'
    bubble.setAttribute('data-legend', legend)
    bubble.classList.add('help-bubble-tip')
    bubble.setAttribute('data-bubble-id', label)
    bubble.textContent = label

    this._bubbles.push({
      bubble,
      targetElement,
      clipAncestors: this.getClipAncestors(targetElement)
    })
    this.attachMouseEvent(bubble)

    return bubble
  },

  getClipAncestors(element) {
    const ancestors = []
    let parent = element.parentElement

    while (parent && parent !== document.body) {
      const { overflow, overflowX, overflowY } = getComputedStyle(parent)
      const clips = [overflow, overflowX, overflowY].some(
        (value) => value && value !== 'visible'
      )

      if (clips) {
        ancestors.push(parent)
      }

      parent = parent.parentElement
    }

    return ancestors
  },

  isAnchorVisible(targetRect, clipAncestors) {
    return clipAncestors.every((ancestor) => {
      const bounds = ancestor.getBoundingClientRect()

      return (
        targetRect.left >= bounds.left &&
        targetRect.left <= bounds.right &&
        targetRect.top >= bounds.top &&
        targetRect.top <= bounds.bottom
      )
    })
  },

  repositionBubbles() {
    this._bubbles.forEach(({ bubble, targetElement, clipAncestors }) => {
      if (!document.body.contains(targetElement)) {
        bubble.style.display = 'none'
        return
      }

      const targetRect = targetElement.getBoundingClientRect()

      if (!this.isAnchorVisible(targetRect, clipAncestors)) {
        bubble.style.display = 'none'
        return
      }

      bubble.style.display = ''
      bubble.style.top = `${targetRect.top + window.scrollY}px`
      bubble.style.left = `${targetRect.left + window.scrollX}px`
    })
  },

  addRepositionListeners() {
    if (this._repositionHandler) return

    this._repositionHandler = () => {
      if (this._repositionRafId) return

      this._repositionRafId = window.requestAnimationFrame(() => {
        this._repositionRafId = null
        this.repositionBubbles()
      })
    }

    window.addEventListener('scroll', this._repositionHandler, true)
    window.addEventListener('resize', this._repositionHandler)
  },

  removeRepositionListeners() {
    if (this._repositionHandler) {
      window.removeEventListener('scroll', this._repositionHandler, true)
      window.removeEventListener('resize', this._repositionHandler)
      this._repositionHandler = null
    }

    if (this._repositionRafId) {
      window.cancelAnimationFrame(this._repositionRafId)
      this._repositionRafId = null
    }

    this._bubbles = []
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

    this.removeRepositionListeners()
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

      el?.removeEventListener('click', this.toggleEvent)
    }
  }
})

document.addEventListener('turbolinks:before-cache', function () {
  TW.workbench.help.teardown()
})
