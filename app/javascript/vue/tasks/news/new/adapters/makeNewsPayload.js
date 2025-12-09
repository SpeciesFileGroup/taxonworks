import { localToUTC } from '@/helpers'

function setDate(date) {
  return date ? utcToLocal(date) : date
}

export function makeNewsPayload(data) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    type: data.type,
    is_public: data.isPublic,
    display_start: setDate(data.start),
    display_end: setDate(data.end)
  }
}
