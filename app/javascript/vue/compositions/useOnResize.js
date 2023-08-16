import { onBeforeUnmount, onMounted, reactive } from 'vue'

export function useOnResize(element) {
  const elementSize = reactive({ width: 0, height: 0 })
  const delay = 100
  let observeElement
  let timeout

  const resizeListener = ({ width, height }) => {
    elementSize.width = width
    elementSize.height = height
  }

  onMounted(() => {
    observeElement = new ResizeObserver((entries) => {
      const { width, height } = entries[0].contentRect

      clearTimeout(timeout)
      timeout = setTimeout(() => {
        resizeListener({ width, height })
      }, delay)
    })

    observeElement.observe(element.value)
  })

  onBeforeUnmount(() => {
    observeElement.disconnect()
  })

  return elementSize
}
