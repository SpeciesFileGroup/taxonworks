export function useUserOkayToLeave(store) {
  if (store.dataChangedSinceLastSave() &&
    !window.confirm(
      'You have unsaved data, are you sure you want to navigate to a new couplet?'
    )
  ) {
    return false
  }
  return true
}
