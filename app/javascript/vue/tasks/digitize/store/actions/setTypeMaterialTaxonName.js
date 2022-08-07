import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ commit, state }, taxonNameId) => {
  const { typeMaterial } = state
  const taxonName = taxonNameId
    ? (await TaxonName.find(taxonNameId)).body
    : null

  commit(MutationNames.SetTypeMaterial, {
    ...typeMaterial,
    protonymId: taxonNameId,
    taxon: taxonName,
    isUnsaved: true
  })
}
