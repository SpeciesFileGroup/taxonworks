import { MutationNames } from '../mutations/mutations'
import { chunkArray } from '@/helpers/arrays.js'
import { Georeference, TaxonName, CollectingEvent } from '@/routes/endpoints'

const MAX_PER_CALL = 50

function getAllCollectingEvents(taxonNames) {
  return new Promise((resolve, reject) => {
    const chunks = chunkArray(
      Array.from(
        new Set(
          taxonNames
            .map((tn) => tn.otus.map((otu) => otu.id))
            .filter((id) => id.length)
        )
      ),
      MAX_PER_CALL
    )
    const collectingEvents = []
    const promises = []

    if (chunks.length) {
      chunks.forEach((ids) => {
        if (ids.length) {
          promises.push(
            CollectingEvent.all({ otu_id: [].concat(...ids) }).then(
              (response) => {
                collectingEvents.push(response.body)
              }
            )
          )
        }
      })
    }
    Promise.all(promises).then(() => {
      const seen = new Set()
      const allCEs = [].concat(...collectingEvents)

      const uniqueCEs = allCEs.filter((el) => {
        const duplicate = seen.has(el.id)
        seen.add(el.id)
        return !duplicate
      })
      resolve(Array.from(uniqueCEs))
    })
  })
}

export default ({ commit, state }, otu) => {
  if (!otu.taxon_name_id) return

  const params = {
    taxon_name_id: [otu.taxon_name_id],
    descendants: true,
    descendants_max_depth: 2,
    extend: ['otus']
  }
  const descendants = {
    taxon_names: [],
    collecting_events: [],
    georeferences: []
  }

  TaxonName.all(params)
    .then((response) => {
      descendants.taxon_names = response.body.filter(
        (tn) => tn.id !== otu.taxon_name_id
      )

      commit(MutationNames.SetDescendants, descendants)
      state.loadState.descendantsDistribution = false
    })
    .finally(() => {
      state.loadState.descendants = false
    })
}
