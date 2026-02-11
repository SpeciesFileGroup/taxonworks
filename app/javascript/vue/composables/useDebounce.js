import { ref, onBeforeUnmount } from 'vue'

export function useDebounce(fn, delay = 300) {
  const timeout = ref(null)

  const debounced = (...args) => {
    clearTimeout(timeout.value)

    timeout.value = setTimeout(() => {
      fn(...args)
    }, delay)
  }

  onBeforeUnmount(() => {
    clearTimeout(timeout.value)
  })

  return debounced
}
