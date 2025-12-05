import { localToUTC } from '@/helpers'

export function makeNewsPayload(data) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    type: data.type,
    is_public: data.isPublic,
    display_start: localToUTC(data.start),
    display_end: localToUTC(data.end)
  }
}
