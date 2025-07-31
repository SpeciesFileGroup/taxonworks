import { onMounted, onBeforeUnmount } from 'vue'

export function useBeforeUnloadListener({
  confirmationMessage = 'You have unsaved changes. Are you sure you want to leave?',
  show
}) {
  const beforeUnloadHandler = (event) => {
    if (show.value) {
      event.returnValue = confirmationMessage

      return confirmationMessage
    }
  }

  onMounted(() => {
    window.addEventListener('beforeunload', beforeUnloadHandler)
  })

  onBeforeUnmount(() => {
    window.removeEventListener('beforeunload', beforeUnloadHandler)
  })
}
