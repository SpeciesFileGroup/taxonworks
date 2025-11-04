import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from '@/routes/endpoints'
import makeTypeMaterial from '@/factory/TypeMaterial.js'

export default ({ commit, state }) => {
  const typeSpecimens = [...state.typeSpecimens]
  const promises = []

  typeSpecimens.forEach((typeSpecimen) => {
    if (!typeSpecimen.isUnsaved) return

    const payload = {
      type_material: makeTypeSpecimenPayback(state, typeSpecimen),
      extend: ['origin_citation']
    }

    const saveRequest = typeSpecimen.id
      ? TypeMaterial.update(typeSpecimen.id, payload)
      : TypeMaterial.create(payload)

    promises.push(saveRequest)

    saveRequest
      .then(({ body }) => {
        commit(
          MutationNames.AddTypeMaterial,
          makeTypeMaterial({ ...typeSpecimen, ...body })
        )
      })
      .catch(() => {})
  })
  return Promise.all(promises)
}

function makeTypeSpecimenPayback(state, typeSpecimen) {
  const payload = {
    id: typeSpecimen.id,
    protonym_id: typeSpecimen.protonymId,
    type_type: typeSpecimen.type,
    collection_object_id: state.collection_object.id
  }

  const { originCitation } = typeSpecimen
  const { id, source_id, ...rest } = originCitation
  const citation = { ...rest, source_id, id }

  if (!source_id && id) {
    citation._destroy = true
  }

  if (source_id || citation._destroy) {
    payload.origin_citation_attributes = citation
  }

  return payload
}
