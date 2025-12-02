export function makeNewsPayload(data) {
  return {
    id: data.id,
    title: data.title,
    body: data.body,
    type: data.type,
    display_start: data.start,
    display_end: data.end
  }
}
