import { marked } from 'marked'

export function listParser(result) {
  return result.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    otu: item.otu.object_tag,
    topic: item.topic.object_tag,
    text: marked.parse(item.text)
  }))
}
