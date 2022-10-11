import { MutationNames } from '../mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'
import makeTypeSpecimen from '../../helpers/makeTypeSpecimen'

export default ({ commit, state }) => {
  const typeSpecimens = [...state.typeSpecimens]
  const promises = []

  typeSpecimens.forEach(typeSpecimen => {
    if (!typeSpecimen.isUnsaved) return

    const payload = {
      type_material: makeTypeSpecimenPayback(state, typeSpecimen),
      extend: ['origin_citation']
    }

    const saveRequest = typeSpecimen.id
      ? TypeMaterial.update(typeSpecimen.id, payload)
      : TypeMaterial.create(payload)

    promises.push(saveRequest)

    saveRequest.then(({ body }) => commit(MutationNames.AddTypeMaterial, makeTypeSpecimen({ ...typeSpecimen, ...body })))
  })

  return Promise.all(promises)
}

function makeTypeSpecimenPayback (state, typeSpecimen) {
  const payload = {
    id: typeSpecimen.id,
    protonym_id: typeSpecimen.protonymId,
    type_type: typeSpecimen.type,
    collection_object_id: state.collection_object.id
  }

  if (typeSpecimen.originCitation) {
    Object.assign(payload, {
      origin_citation_attributes: {
        id: typeSpecimen.originCitation.id,
        source_id: typeSpecimen.originCitation.source_id,
        pages: typeSpecimen.originCitation.pages
      }
    })
  }

  return payload
}
