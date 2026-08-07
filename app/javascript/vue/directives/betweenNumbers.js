export const vBetweenNumbers = {
  mounted: (el, binding, vnode) => {
    const [min, max] = binding.value

    el.handler = () => {
      const { value } = el

      if (!value) {
        return
      }

      if (value < min) {
        el.value = min
        vnode.el.dispatchEvent(new CustomEvent('input'))
      } else if (value > max) {
        el.value = max
        vnode.el.dispatchEvent(new CustomEvent('input'))
      }
    }

    el.addEventListener('change', el.handler)
  },
  unmounted: (el) => {
    el.removeEventListener('change', el.handler)
  }
}
