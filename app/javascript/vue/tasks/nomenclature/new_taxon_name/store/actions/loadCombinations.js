import { Combination, TaxonName } from 'routes/endpoints'
import { combinationIcnType } from '../../const/originalCombinationTypes'

const extend = ['protonyms', 'origin_citation', 'roles']
const ranks = [
  ...Object.keys(combinationIcnType.genusGroup),
  ...Object.keys(combinationIcnType.speciesGroup)
].reverse()

export default ({ state, dispatch }, id) => {
  TaxonName.where({ combination_taxon_name_id: [id] }).then(({ body }) => {
    const requests = body.map(taxon => Combination.find(taxon.id, { extend }))

    Promise.all(requests).then(responses => {
      const combinations = responses.map(({ body }) => body)

      state.combinations = combinations.filter(({ protonyms }) => {
        const lastRank = ranks.find(rank => protonyms[rank])

        return protonyms[lastRank].id === id
      })

      dispatch('loadSoftValidation', 'combinations')
    })
  })
}
