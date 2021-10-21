import { Combination, TaxonName } from 'routes/endpoints'

export default ({ state }, id) => {
  TaxonName.where({ combination_taxon_name_id: [id] }).then(({ body }) => {
    const requests = body.map(taxon => Combination.find(taxon.id, { extend: ['protonyms'] }))

    Promise.all(requests).then(responses => {
      const combinations = responses.map(({ body }) => body)

      state.combinations = combinations.filter(combination => {
        const { [Object.keys(combination.protonyms).pop()]: taxon } = combination.protonyms

        return taxon.id === id
      })
    })
  })
}
