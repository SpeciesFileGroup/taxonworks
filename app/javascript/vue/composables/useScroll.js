import { isRef, toRefs, reactive, onMounted, onUnmounted } from 'vue'

export function useScroll (elementRef) {
  const scroll = reactive({
    x: 0,
    y: 0
  })

  const updateScrollWithWindow = () => {
    ({ pageXOffset: scroll.x, pageYOffset: scroll.y } = window)
  }

  const updateScrollWithElement = _ => {
    ({ scrollLeft: scroll.x, scrollTop: scroll.y } = elementRef.value)
  }

  const handleScroll = _ => {
    if (elementRef === window) {
      updateScrollWithWindow()
    } else {
      updateScrollWithElement()
    }
  }

  onMounted(() => isRef(elementRef)
    ? elementRef.value.addEventListener('scroll', handleScroll)
    : elementRef.addEventListener('scroll', handleScroll)
  )
  onUnmounted(() => isRef(elementRef)
    ? elementRef.value.removeEventListener('scroll', handleScroll)
    : elementRef.removeEventListener('scroll', handleScroll)
  )
  return toRefs(scroll)
}
