import { randomUUID } from '@/helpers'

export default (typeData = {}) => ({
  id: typeData.id,
  uuid: typeData.uuid || randomUUID(),
  type: typeData.type_type,
  protonymId: typeData.protonym_id,
  label: typeData.object_tag,
  collectionObjectId: typeData.collection_object_id,
  globalId: typeData.global_id,
  taxon: undefined,
  isUnsaved: false
})
