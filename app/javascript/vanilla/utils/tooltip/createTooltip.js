import {
  computePosition,
  autoUpdate,
  offset,
  flip,
  shift,
  arrow
} from '@floating-ui/dom'

const ARROW_SIZE = 8
const OFFSET = 8
const HIDE_DELAY = 150

const STATIC_SIDE = {
  top: 'bottom',
  right: 'left',
  bottom: 'top',
  left: 'right'
}

let idCounter = 0

export function createTooltip(referenceEl, options = {}) {
  let content = options.content ?? ''
  let placement = options.placement || 'bottom'
  let html = options.html ?? false

  const tooltipEl = document.createElement('div')
  tooltipEl.className = 'tw-tooltip'
  tooltipEl.setAttribute('role', 'tooltip')
  tooltipEl.id = `tw-tooltip-${++idCounter}`

  const contentEl = document.createElement('div')
  contentEl.className = 'tw-tooltip__content'

  const arrowEl = document.createElement('div')
  arrowEl.className = 'tw-tooltip__arrow'

  tooltipEl.append(contentEl, arrowEl)

  let cleanupAutoUpdate = null
  let hideTimer = null
  let visible = false

  function renderContent() {
    if (html) {
      contentEl.innerHTML = content
    } else {
      contentEl.textContent = content
    }
  }

  function update() {
    return computePosition(referenceEl, tooltipEl, {
      placement,
      middleware: [
        offset(OFFSET),
        flip(),
        shift({ padding: 5 }),
        arrow({ element: arrowEl })
      ]
    }).then(({ x, y, placement: finalPlacement, middlewareData }) => {
      Object.assign(tooltipEl.style, {
        left: `${x}px`,
        top: `${y}px`
      })

      const side = finalPlacement.split('-')[0]
      tooltipEl.setAttribute('data-placement', side)

      const arrowData = middlewareData.arrow

      if (arrowData) {
        Object.assign(arrowEl.style, {
          left: arrowData.x != null ? `${arrowData.x}px` : '',
          top: arrowData.y != null ? `${arrowData.y}px` : '',
          right: '',
          bottom: '',
          [STATIC_SIDE[side]]: `${-ARROW_SIZE / 2}px`
        })
      }
    })
  }

  function show() {
    clearTimeout(hideTimer)
    hideTimer = null

    if (visible || !content) return

    visible = true
    renderContent()
    document.body.appendChild(tooltipEl)
    cleanupAutoUpdate = autoUpdate(referenceEl, tooltipEl, update)

    requestAnimationFrame(() => {
      if (visible) tooltipEl.setAttribute('data-show', '')
    })
  }

  function remove() {
    cleanupAutoUpdate?.()
    cleanupAutoUpdate = null
    tooltipEl.remove()
  }

  function hide() {
    if (!visible) return

    visible = false
    tooltipEl.removeAttribute('data-show')
    hideTimer = setTimeout(remove, HIDE_DELAY)
  }

  function setOptions(opts = {}) {
    if ('content' in opts) content = opts.content ?? ''
    if ('placement' in opts) placement = opts.placement || 'bottom'
    if ('html' in opts) html = opts.html

    if (visible) {
      if (!content) {
        hide()
      } else {
        renderContent()
        update()
      }
    }
  }

  function destroy() {
    clearTimeout(hideTimer)
    visible = false
    remove()
  }

  return {
    show,
    hide,
    update,
    setOptions,
    destroy,
    get id() {
      return tooltipEl.id
    },
    get element() {
      return tooltipEl
    }
  }
}
