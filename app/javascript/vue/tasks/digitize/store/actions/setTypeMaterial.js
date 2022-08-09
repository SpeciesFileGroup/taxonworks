import { TaxonName } from 'routes/endpoints'

export default ({ state }, typeMaterial) => {
  if (!typeMaterial.taxon) {
    const request = TaxonName.find(typeMaterial.protonymId)

    request.then(({ body }) => {
      state.typeMaterial = {
        ...typeMaterial,
        taxon: body
      }
    })
  } else {
    state.typeMaterial = { ...typeMaterial }
  }
}
