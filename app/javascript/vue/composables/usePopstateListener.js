import { onBeforeUnmount } from 'vue'

export function usePopstateListener(handlePopstateEvent) {
  function removeListener() {
    window.removeEventListener('popstate', handlePopstateEvent)
  }

  window.addEventListener('popstate', handlePopstateEvent)

  onBeforeUnmount(removeListener)
}
