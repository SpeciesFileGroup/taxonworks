const getPastDateByDays = (days) => {
  const date = new Date()
  date.setDate(date.getDate() - days)

  return date.toISOString().slice(0, 10)
}

function formatDate(date) {
  const twoDigits = (num) => num.toString().padStart(2, '0')

  const year = date.getFullYear()
  const month = twoDigits(date.getMonth() + 1)
  const day = twoDigits(date.getDate())
  const hours = twoDigits(date.getHours())
  const minutes = twoDigits(date.getMinutes())
  const seconds = twoDigits(date.getSeconds())

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

export { getPastDateByDays, formatDate }
