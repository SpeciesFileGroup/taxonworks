export const numberOnly = {
  mounted: el => {
    el.handler = () => {
      el.value = el.value.replace(/[^\d]/g, '')
    }
    el.addEventListener('input', el.handler)
  },
  unmounted: el => {
    el.removeEventListener('input', el.handler)
  }
}
