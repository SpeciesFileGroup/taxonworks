import { utcToLocal } from '@/helpers'

function formatDateTime(date) {
  const pad = (n) => String(n).padStart(2, '0')

  const year = date.getUTCFullYear()
  const month = pad(date.getUTCMonth() + 1)
  const day = pad(date.getUTCDate())
  const hours = pad(date.getUTCHours())
  const minutes = pad(date.getUTCMinutes())

  return `${year}-${month}-${day} ${hours}:${minutes}`
}

function setDate(date) {
  return date ? formatDateTime(utcToLocal(date)) : date
}

export function makeNews(data = {}) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    isPublic: data.is_public,
    bodyHtml: data.body_html,
    type: data.type,
    start: setDate(data.display_start),
    end: setDate(data.display_end)
  }
}
