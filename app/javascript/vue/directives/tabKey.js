export const vTabkey = {
  mounted: (el, binding, vnode) => {
    el.handler = (e) => {
      if (e.key === 'Tab') {
        e.preventDefault()

        el.setRangeText('	', el.selectionStart, el.selectionEnd, 'end')
        vnode.el.dispatchEvent(new CustomEvent('input'))
      }
    }

    el.addEventListener('keydown', el.handler)
  },
  unmounted: (el) => {
    el.removeEventListener('keydown', el.handler)
  }
}
