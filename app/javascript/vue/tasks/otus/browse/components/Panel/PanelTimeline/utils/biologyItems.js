import { makeGlobalId } from '@/helpers'

export const TIMELINE_ITEM_BIOLOGY = 'biology'

const sourceKey = (source) => makeGlobalId({ id: source.id, type: 'Source' })
const topicKey = (topic) =>
  makeGlobalId({ id: topic.id, type: 'ControlledVocabularyTerm' })

export function biologyItems(inventory, otuIds) {
  const ids = new Set(otuIds)

  return inventory
    .filter((entry) => ids.has(entry.otu.id))
    .flatMap(({ otu, citations }) =>
      citations
        .filter((c) => c.source?.id)
        .map((c) => ({
          kind: TIMELINE_ITEM_BIOLOGY,
          id: c.id,
          type: c.citation_object_type,
          label: [c.source.author_year, c.pages].filter(Boolean).join(':'),
          otu,
          source: c.source,
          citationTopics: c.topics,
          topics: c.topics.map(topicKey),
          data_attributes: {
            'history-object-id': otu.global_id,
            'history-source-id': sourceKey(c.source),
            'history-year': c.source.year ?? 'unknown'
          }
        }))
    )
}

export function biologySources(items) {
  return Object.fromEntries(
    items.map(({ source }) => [
      sourceKey(source),
      { cached: source.cached, year: source.year }
    ])
  )
}

export function biologyTopics(items) {
  return Object.fromEntries(
    items.flatMap(({ citationTopics }) =>
      citationTopics.map((t) => [
        topicKey(t),
        { name: t.name, css_color: t.css_color }
      ])
    )
  )
}
