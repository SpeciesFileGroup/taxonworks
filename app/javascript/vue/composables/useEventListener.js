import { onMounted, onBeforeUnmount, unref } from 'vue'

export function useEventListener(target, eventName, func, options = {}) {
  onMounted(() => {
    const t = unref(target)

    t.addEventListener(eventName, func, options)
  })

  onBeforeUnmount(() => {
    const t = unref(target)

    t.removeEventListener(eventName, func, options)
  })
}
