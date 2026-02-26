import { ref, onMounted, onUnmounted, isRef } from 'vue'

export function useStickyBelow(rootRef, elementRef, offsetRef = '.navbar-fixed-top') {
  const navbarOffset = ref(0)
  const isFixed = ref(false)

  const resolveOffsetElement = () => {
    if (isRef(offsetRef)) return offsetRef.value
    if (offsetRef instanceof HTMLElement) return offsetRef
    return document.querySelector(offsetRef)
  }

  const getNavbarOffset = () => {
    const offsetElement = resolveOffsetElement()
    return offsetElement
      ? offsetElement.getBoundingClientRect().bottom +
          parseFloat(getComputedStyle(offsetElement.parentElement).marginBottom)
      : 0
  }

  const update = () => {
    navbarOffset.value = getNavbarOffset()

    const shouldFix =
      rootRef.value.offsetTop <
      document.documentElement.scrollTop + navbarOffset.value

    if (shouldFix && !isFixed.value) {
      const width = elementRef.value.getBoundingClientRect().width
      elementRef.value.style.width = `${width}px`
      elementRef.value.style.position = 'fixed'
      isFixed.value = true
    } else if (!shouldFix && isFixed.value) {
      elementRef.value.style.width = ''
      elementRef.value.style.position = ''
      elementRef.value.style.top = ''
      isFixed.value = false
    }

    if (isFixed.value) {
      elementRef.value.style.top = `${navbarOffset.value}px`
    }
  }

  onMounted(() => {
    window.addEventListener('scroll', update)
    update()
  })

  onUnmounted(() => {
    window.removeEventListener('scroll', update)
  })

  return { navbarOffset, isFixed }
}
