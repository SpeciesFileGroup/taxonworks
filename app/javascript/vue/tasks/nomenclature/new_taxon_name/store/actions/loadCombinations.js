import { TaxonName } from '@/routes/endpoints'
import { combinationIcnType } from '../../const/combinationTypes'
import { COMBINATION } from '@/constants'

const extend = ['protonyms', 'origin_citation', 'roles']
const ranks = [
  ...Object.keys(combinationIcnType.genusGroup),
  ...Object.keys(combinationIcnType.SpeciesAndInfraspeciesGroup)
].reverse()

export default ({ state, dispatch }, id) => {
  TaxonName.all({
    combination_taxon_name_id: [id],
    taxon_name_type: COMBINATION,
    extend: ['protonyms']
  }).then(({ body }) => {
    const combinations = body.filter(({ protonyms }) => {
      const lastRank = ranks.find((rank) => protonyms[rank])

      return protonyms[lastRank].id === id
    })

    if (combinations.length) {
      TaxonName.all({
        taxon_name_id: combinations.map((c) => c.id),
        taxon_name_type: COMBINATION,
        extend
      }).then(({ body }) => {
        state.combinations = body
        dispatch('loadSoftValidation', 'combinations')
      })
    }
  })
}
