import { createTooltip } from '../utils/tooltip/createTooltip'

const SELECTOR = '[data-tooltip-content]'
const instances = new WeakMap()

function readOptions(el) {
  return {
    content: el.getAttribute('data-tooltip-content') || '',
    placement: el.getAttribute('data-tooltip-placement') || 'bottom'
  }
}

function getController(el) {
  let controller = instances.get(el)

  if (controller) {
    controller.setOptions(readOptions(el))
  } else {
    controller = createTooltip(el, readOptions(el))
    instances.set(el, controller)
  }

  return controller
}

function onShow(event) {
  const el = event.target.closest?.(SELECTOR)

  if (!el || el.contains(event.relatedTarget)) return

  getController(el).show()
}

function onHide(event) {
  const el = event.target.closest?.(SELECTOR)

  if (!el || el.contains(event.relatedTarget)) return

  instances.get(el)?.hide()
}

function addListeners() {
  document.body.addEventListener('mouseover', onShow)
  document.body.addEventListener('mouseout', onHide)
  document.body.addEventListener('focusin', onShow)
  document.body.addEventListener('focusout', onHide)
}

function destroyTooltips() {
  document.body.removeEventListener('mouseover', onShow)
  document.body.removeEventListener('mouseout', onHide)
  document.body.removeEventListener('focusin', onShow)
  document.body.removeEventListener('focusout', onHide)

  document
    .querySelectorAll('.tw-tooltip')
    .forEach((tooltip) => tooltip.remove())
}

document.addEventListener('turbolinks:load', addListeners)
document.addEventListener('turbolinks:before-render', destroyTooltips)
