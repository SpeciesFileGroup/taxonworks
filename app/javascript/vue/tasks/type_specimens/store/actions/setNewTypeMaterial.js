import { MutationNames } from '../mutations/mutations'
import Identifier from '../../const/identifier'

export default ({ commit, state }) => {
  const type_material = {
    id: undefined,
    protonym_id: state.type_material.protonym_id,
    collection_object: undefined,
    collection_object_id: undefined,
    type_type: undefined,
    roles_attributes: [],
    collection_object_attributes: {
      id: undefined,
      total: 1,
      preparation_type_id: undefined,
      repository_id: undefined,
      collecting_event_id: undefined,
      buffered_collecting_event: undefined,
      buffered_determinations: undefined,
      buffered_other_labels: undefined
    },
    origin_citation_attributes: {
      source_id: undefined,
      pages: undefined
    },
    origin_citation: undefined
  }

  commit(MutationNames.SetTypeMaterial, type_material)
  commit(MutationNames.SetIdentifier, Identifier())
  commit(MutationNames.SetSoftValidation, [])
}
