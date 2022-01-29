import { onMounted, onUnmounted, reactive, toRefs } from 'vue'

export function useWindowSize () {
  const windowSize = reactive({ width: 0, height: 0 })
  const resizeListener = () => {
    ({ innerWidth: windowSize.width, innerHeight: windowSize.height } = window)
  }

  onMounted(() => window.addEventListener('resize', resizeListener))
  onUnmounted(() => window.removeEventListener('resize', resizeListener))
  resizeListener()

  return toRefs(windowSize)
}
