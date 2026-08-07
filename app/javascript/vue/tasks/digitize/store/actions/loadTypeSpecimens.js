import { TypeMaterial, Citation } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { TYPE_MATERIAL } from '@/constants'
import makeTypeMaterial from '@/factory/TypeMaterial.js'
import makeCitation from '@/factory/Citation.js'

export default async ({ commit }, id) => {
  try {
    const { body: typeMaterialData } = await TypeMaterial.where({
      collection_object_id: id
    })

    const typeMaterials = typeMaterialData.map(makeTypeMaterial)
    const typeMaterialIds = typeMaterials.map((item) => item.id)

    const { body: citations } = await Citation.where({
      citation_object_id: typeMaterialIds,
      citation_object_type: TYPE_MATERIAL,
      is_original: true
    })

    const typeMaerialsWithCitations = typeMaterials.map((item) => {
      const citation = citations.find((c) => c.citation_object_id === item.id)

      return {
        ...item,
        citation: { ...makeCitation(TYPE_MATERIAL), ...citation }
      }
    })

    commit(MutationNames.SetTypeMaterials, typeMaerialsWithCitations)

    return typeMaerialsWithCitations
  } catch (error) {
    throw error
  }
}
