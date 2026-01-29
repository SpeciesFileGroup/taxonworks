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

export function buildDownloadFilename(prefix, index, total) {
  const date = new Date()
  const formatted = `${date.getMonth() + 1}_${date.getDate()}_${String(
    date.getFullYear()
  ).slice(-2)}`
  return `TaxonWorks-${prefix}-${formatted}-${index}_of_${total}.zip`
}

export function clampMaxMb(value, min = 10, max = 1000) {
  const parsed = Number(value)
  if (Number.isNaN(parsed)) return max
  return Math.min(max, Math.max(min, Math.round(parsed)))
}
