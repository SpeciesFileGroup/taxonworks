import { useRandomUUID } from 'helpers/random'
import makeCitation from 'factory/Citation'

export default (typeData = {}) => ({
  id: typeData.id,
  internalId: typeData.internalId || useRandomUUID(),
  type: typeData.type_type,
  protonymId: typeData.protonym_id,
  label: typeData.object_tag,
  collectionObjectId: typeData.collection_object_id,
  roles: typeData.roles || [],
  originCitation: getCitation(typeData),
  globalId: typeData.global_id,
  taxon: undefined,
  isUnsaved: false
})

function getCitation (data) {
  const citation = data.origin_citation_attributes || data.origin_citation || makeCitation()

  if (citation.source) {
    citation.source_id = citation.source.id
  }

  return {
    id: citation.id,
    source_id: citation.source_id,
    pages: citation.pages
  }
}
