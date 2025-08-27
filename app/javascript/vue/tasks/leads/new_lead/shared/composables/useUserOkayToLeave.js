export function useUserOkayToLeave(store, message) {
  message ||= 'You have unsaved data, are you sure you want to navigate to a new couplet?'
  if (store.dataChangedSinceLastSave() && !window.confirm(message)) {
    return false
  }
  return true
}
