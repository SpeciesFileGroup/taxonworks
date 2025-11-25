export function getPastDateByDays(days) {
  const date = new Date()
  date.setDate(date.getDate() - days)

  return date.toISOString().slice(0, 10)
}

export function formatDate(date) {
  const twoDigits = (num) => num.toString().padStart(2, '0')

  const year = date.getFullYear()
  const month = twoDigits(date.getMonth() + 1)
  const day = twoDigits(date.getDate())
  const hours = twoDigits(date.getHours())
  const minutes = twoDigits(date.getMinutes())
  const seconds = twoDigits(date.getSeconds())

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

export function timeAgo(dateInput) {
  const date = new Date(dateInput)
  const now = new Date()
  const seconds = Math.floor((now - date) / 1000)

  const intervals = {
    year: 365 * 24 * 60 * 60,
    month: 30 * 24 * 60 * 60,
    day: 24 * 60 * 60,
    hour: 60 * 60,
    minute: 60,
    second: 1
  }

  for (const [unit, value] of Object.entries(intervals)) {
    const count = Math.floor(seconds / value)
    if (count >= 1) {
      return `${count} ${unit}${count > 1 ? 's' : ''} ago`
    }
  }

  return 'just now'
}
