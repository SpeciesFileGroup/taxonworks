import { onMounted, onUnmounted, reactive } from 'vue'

export function useOnResize (element) {
  const elementSize = reactive({ width: 0, height: 0 })
  let observeElement

  const resizeListener = ({ width, height }) => {
    elementSize.width = width
    elementSize.height = height

    console.log(width, height)
  }

  onMounted(() => {
    observeElement = new ResizeObserver(entries => {
      const { width, height } = entries[0].contentRect

      resizeListener({ width, height })
    })

    observeElement.observe(element.value)
  })

  onUnmounted(() => {
    observeElement.disconnect()
  })

  return elementSize
}
