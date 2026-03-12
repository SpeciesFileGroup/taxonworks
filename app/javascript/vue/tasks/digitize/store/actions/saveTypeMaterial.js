import { MutationNames } from '../mutations/mutations'
import { TypeMaterial, Citation } from '@/routes/endpoints'
import makeTypeMaterial from '@/factory/TypeMaterial.js'
import makeCitation from '@/factory/Citation'
import { TYPE_MATERIAL } from '@/constants'

export default async ({ commit, state }) => {
  const typeSpecimens = [...state.typeSpecimens]
  const promises = []

  for (const typeSpecimen of typeSpecimens) {
    const { citation, isUnsaved, id } = typeSpecimen

    if (isUnsaved) {
      const payload = {
        type_material: makeTypeSpecimenPayback(state, typeSpecimen)
      }

      try {
        const saveRequest = id
          ? TypeMaterial.update(id, payload)
          : TypeMaterial.create(payload)

        promises.push(saveRequest)

        const { body } = await saveRequest
        const savedRecord = {
          ...makeTypeMaterial({ ...typeSpecimen, ...body }),
          citation
        }

        if (citation.isUnsaved) {
          await saveCitation(savedRecord)
        }

        commit(MutationNames.AddTypeMaterial, savedRecord)
        promises.push(Promise.resolve())
      } catch (error) {
        promises.push(Promise.reject(error))
      }
    }
  }

  return Promise.allSettled(promises)
}

function makeCitationPayload(citation) {
  return {
    id: citation.id,
    source_id: citation.source_id,
    pages: citation.pages,
    citation_object_type: TYPE_MATERIAL,
    is_original: true
  }
}

async function saveCitation(typeMaterial) {
  const citationPayload = {
    ...makeCitationPayload(typeMaterial.citation),
    citation_object_id: typeMaterial.id
  }
  const hasCitationId = Boolean(citationPayload.id)
  const hasSourceId = Boolean(citationPayload.source_id)

  try {
    if (!hasSourceId && hasCitationId) {
      await Citation.destroy(citationPayload.id)

      typeMaterial.citation = makeCitation(TYPE_MATERIAL)
    } else {
      const payload = {
        citation: citationPayload
      }

      const { body } = citationPayload.id
        ? await Citation.update(citationPayload.id, payload)
        : await Citation.create(payload)

      typeMaterial.citation.id = body.id
    }

    typeMaterial.citation.isUnsaved = false
  } catch {}
}

function makeTypeSpecimenPayback(state, typeSpecimen) {
  const payload = {
    id: typeSpecimen.id,
    protonym_id: typeSpecimen.protonymId,
    type_type: typeSpecimen.type,
    collection_object_id: state.collection_object.id
  }

  return payload
}
