import { delegate } from 'tippy.js'

const DEFAULT_OPTIONS = {
  placement: 'bottom'
}

let instance = null

function destroyDelegate() {
  if (instance) {
    instance?.forEach((tippy) => tippy.destroy())
    instance = null
  }
}

function initTippy() {
  destroyDelegate()

  instance = delegate('body', {
    ...DEFAULT_OPTIONS,
    target: '[data-tippy-content]'
  })
}

document.addEventListener('turbolinks:load', initTippy)
document.addEventListener('turbolinks:before-render', destroyDelegate)
