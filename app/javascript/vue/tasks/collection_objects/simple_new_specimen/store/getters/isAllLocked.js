export default state => {
  const lockValues = Object.values(state.settings.lock)

  return lockValues.every(Boolean)
}
