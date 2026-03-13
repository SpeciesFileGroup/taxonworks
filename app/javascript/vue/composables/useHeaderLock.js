import { ref, onMounted, onUnmounted } from 'vue'

export function useHeaderLock() {
  const isLocked = ref(false)

  let header
  let wrapper
  let observer

  function syncHeight() {
    if (!isLocked.value) return

    wrapper.style.height = `${header.offsetHeight}px`
  }

  function lock() {
    isLocked.value = true
    header.classList.add('fixed_header_bar')
    syncHeight()
  }

  function unlock() {
    isLocked.value = false
    header.classList.remove('fixed_header_bar')
    wrapper.style.height = 'auto'
  }

  function toggle() {
    isLocked.value ? unlock() : lock()
  }

  onMounted(() => {
    header = document.querySelector('#header-wrapper')
    wrapper = document.querySelector('header')

    observer = new ResizeObserver(syncHeight)
    observer.observe(header)
  })

  onUnmounted(() => {
    observer?.disconnect()
  })

  return {
    isLocked,
    toggle,
    unlock,
    lock
  }
}
