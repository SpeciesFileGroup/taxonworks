import { useRandomUUID } from 'helpers/random'

export default (typeData = {}) => ({
  id: typeData.id,
  internalId: typeData.internalId || useRandomUUID(),
  type: typeData.type_type,
  protonymId: typeData.protonym_id,
  label: typeData.object_tag,
  collectionObjectId: typeData.collection_object_id,
  roles: typeData.roles || [],
  originCitation: typeData.origin_citation_attributes,
  globalId: typeData.global_id,
  taxon: undefined,
  isUnsaved: false
})

/* 
const asdf = () => ({
  id: undefined,
  global_id: undefined,
  protonym_id: undefined,
  taxon: undefined,
  collection_object_id: undefined,
  type_type: undefined,
  roles_attributes: [],
  collection_object: undefined,
  origin_citation_attributes: undefined,
  type_designator_roles: []
})
 */