export function makePreviewObject(newVal, oldVal) {
  return {
    value: newVal,
    hasChanged: newVal !== oldVal
  }
}
