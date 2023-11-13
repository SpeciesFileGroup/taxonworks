import { MutationNames } from '../mutations/mutations'
import { BiologicalAssociation } from '@/routes/endpoints'
import ActionNames from './actionNames'

const extend = [
  'biological_relationship',
  'biological_relationship_types',
  'citations',
  'object',
  'source',
  'subject',
  'taxonomy'
]

function getBiologicalProperty(biologicalRelationshipTypes, type) {
  return biologicalRelationshipTypes.find((r) => r.target === type)
    ?.biological_property?.name
}

function parseRank(rank) {
  return Array.isArray(rank) ? rank.filter(Boolean).join(' ') : rank
}

function authorString(citation) {
  const pages = citation.pages ? `:${citation.pages}` : ''

  return `${citation.source.author_year}${
    citation.source.year_suffix || ''
  }${pages}`
}

export function listAdapter(result) {
  return result.map((item) => ({
    id: item.id,
    globalId: item.global_id,
    subjectId: item.subject.id,
    subjectType: item.subject.base_class,
    subjectOrder: parseRank(item.subject?.taxonomy?.order),
    subjectFamily: parseRank(item.subject?.taxonomy?.family),
    subjectGenus: parseRank(item.subject?.taxonomy?.genus),
    subjectLabel: item.subject.object_label,
    subjectTag: item.subject.object_tag,
    biologicalPropertySubject: getBiologicalProperty(
      item.biological_relationship_types,
      'subject'
    ),
    biologicalRelationship: item.biological_relationship.object_tag,
    biologicalRelationshipId: item.biological_relationship_id,
    biologicalPropertyObject: getBiologicalProperty(
      item.biological_relationship_types,
      'object'
    ),
    objectId: item.object.id,
    objectType: item.object.base_class,
    objectOrder: parseRank(item.object?.taxonomy?.order),
    objectFamily: parseRank(item.object?.taxonomy?.family),
    objectGenus: parseRank(item.object?.taxonomy?.genus),
    objectLabel: item.object.object_label,
    objectTag: item.object.object_tag,
    source: item.source,
    citations: item.citations.map((citation) => ({
      ...citation,
      label: authorString(citation)
    }))
  }))
}

export default async ({ state, commit, dispatch }, globalId) => {
  const { body } = await BiologicalAssociation.all({
    any_global_id: [globalId],
    extend
  })

  const data = listAdapter(body)

  commit(
    MutationNames.SetBiologicalAssociations,
    state.biologicalAssociations.concat(data)
  )
}
