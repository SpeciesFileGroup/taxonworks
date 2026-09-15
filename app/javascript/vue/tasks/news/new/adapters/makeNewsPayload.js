import { localToUTC } from '@/helpers'
import { NEWS_PROJECT_BLOGPOST } from '@/constants/news'

function setDate(date) {
  return date ? localToUTC(date) : date
}

export function makeNewsPayload(data) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    type: data.type,
    is_public: data.type === NEWS_PROJECT_BLOGPOST && !!data.isPublic,
    display_start: setDate(data.start),
    display_end: setDate(data.end)
  }
}
