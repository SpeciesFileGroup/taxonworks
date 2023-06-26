import { OTU } from 'constants/index.js'
import { RouteNames } from 'routes/routes'

function getBiologicalProperty(biologicalRelationshipTypes, type) {
  return biologicalRelationshipTypes.find((r) => r.target === type)
    ?.biological_property?.name
}

function parseRank(rank) {
  return Array.isArray(rank) ? rank.filter(Boolean).join(' ') : rank
}

function makeLink({ id, type, label }) {
  const param = type === OTU ? 'otu_id' : 'collection_object_id'
  const url =
    type === OTU ? RouteNames.BrowseOtu : RouteNames.BrowseCollectionObject

  return `<a href="${url}?${param}=${id}">${label}</a>`
}

export function listParser(result) {
  return result.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    subject_taxonomy_order: parseRank(item.subject?.taxonomy?.order),
    subject_taxonomy_family: parseRank(item.subject?.taxonomy?.family),
    subject_taxonomy_genus: parseRank(item.subject?.taxonomy?.genus),
    subject_object_tag: makeLink({
      label: item.subject.object_tag,
      id: item.biological_association_subject_id,
      type: item.biological_association_subject_type
    }),
    biological_property_subject: getBiologicalProperty(
      item.biological_relationship_types,
      'subject'
    ),
    biological_relationship: item.biological_relationship.object_tag,
    biological_property_object: getBiologicalProperty(
      item.biological_relationship_types,
      'object'
    ),
    object_taxonomy_order: parseRank(item.object?.taxonomy?.order),
    object_taxonomy_family: parseRank(item.object?.taxonomy?.family),
    object_taxonomy_genus: parseRank(item.object?.taxonomy?.genus),
    object_object_tag: makeLink({
      label: item.object.object_tag,
      id: item.biological_association_object_id,
      type: item.biological_association_object_type
    })
  }))
}
