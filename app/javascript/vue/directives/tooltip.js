import { createTooltip } from '../../vanilla/utils/tooltip/createTooltip'

const entries = new WeakMap()

function normalize(value) {
  if (typeof value === 'string') {
    return { content: value, placement: 'bottom' }
  }

  return {
    content: value?.content ?? '',
    placement: value?.placement ?? 'bottom',
    html: value?.html ?? false
  }
}

export const vTooltip = {
  mounted(el, binding) {
    const controller = createTooltip(el, normalize(binding.value))

    const show = () => {
      controller.show()
      el.setAttribute('aria-describedby', controller.id)
    }

    const hide = () => {
      controller.hide()
      el.removeAttribute('aria-describedby')
    }

    el.addEventListener('mouseenter', show)
    el.addEventListener('mouseleave', hide)
    el.addEventListener('focusin', show)
    el.addEventListener('focusout', hide)

    entries.set(el, { controller, show, hide })
  },

  updated(el, binding) {
    entries.get(el)?.controller.setOptions(normalize(binding.value))
  },

  beforeUnmount(el) {
    const entry = entries.get(el)

    if (!entry) return

    el.removeEventListener('mouseenter', entry.show)
    el.removeEventListener('mouseleave', entry.hide)
    el.removeEventListener('focusin', entry.show)
    el.removeEventListener('focusout', entry.hide)
    entry.controller.destroy()
    entries.delete(el)
  }
}
