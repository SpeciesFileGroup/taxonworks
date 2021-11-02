export const numberOnly = {
  mounted: (el, binding, vnode) => {
    el.handler = () => {
      if (/[^\d]/g.test(el.value)) {
        el.value = el.value.replace(/[^\d]/g, '')
        vnode.el.dispatchEvent(new CustomEvent('input'))
      }
    }
    el.addEventListener('input', el.handler)
  },
  unmounted: el => {
    el.removeEventListener('input', el.handler)
  }
}
