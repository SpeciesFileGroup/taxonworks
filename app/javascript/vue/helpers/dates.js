const getPastDateByDays = (days, date = new Date()) => {
  date.setDate(date.getDate() - days)

  return date.toISOString().slice(0, 10)
}

export {
  getPastDateByDays
}
