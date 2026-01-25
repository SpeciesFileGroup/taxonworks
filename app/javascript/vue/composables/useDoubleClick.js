import { onBeforeUnmount } from 'vue'

const DEFAULT_DELAY = 250

export function useDoubleClick(onSingleClick, onDoubleClick, delay = DEFAULT_DELAY) {
  let clickTimer = null

  function handleClick(...args) {
    if (clickTimer == null) {
      clickTimer = setTimeout(() => {
        clickTimer = null
        onSingleClick(...args)
      }, delay)
    }
  }

  function handleDoubleClick(...args) {
    clearTimeout(clickTimer)
    clickTimer = null
    onDoubleClick(...args)
  }

  onBeforeUnmount(() => {
    clearTimeout(clickTimer)
  })

  return { handleClick, handleDoubleClick }
}
