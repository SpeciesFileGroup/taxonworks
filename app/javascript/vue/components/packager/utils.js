export const MIN_MAX_MB = 10
export const MAX_MAX_MB = 1000

export function formatBytes(value, decimals = 1) {
  const bytes = Number(value) || 0
  if (bytes === 0) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB']
  const exponent = Math.min(
    Math.floor(Math.log(bytes) / Math.log(1000)),
    units.length - 1
  )
  const size = bytes / 1000 ** exponent
  return `${size.toFixed(decimals)} ${units[exponent]}`
}

export function clampMaxMb(value, min = MIN_MAX_MB, max = MAX_MAX_MB) {
  const parsed = Number(value)
  if (Number.isNaN(parsed)) return max
  return Math.min(max, Math.max(min, Math.round(parsed)))
}
