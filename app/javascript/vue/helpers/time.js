export function secondsToTimeString(seconds) {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = Math.floor(seconds % 60)
  const ms = Math.round((seconds % 1) * 1000)

  return (
    [h, m, s].map((unit) => String(unit).padStart(2, '0')).join(':') +
    '.' +
    String(ms).padStart(3, '0')
  )
}
