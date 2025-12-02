function formatDateTime(isoString) {
  if (!isoString) return isoString

  const d = new Date(isoString)
  const [date, time] = d.toISOString().split('T')
  return `${date} ${time.slice(0, 5)}`
}

export function makeNews(data = {}) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    bodyHtml: data.body_html,
    type: data.type,
    start: formatDateTime(data.display_start),
    end: formatDateTime(data.display_end)
  }
}
