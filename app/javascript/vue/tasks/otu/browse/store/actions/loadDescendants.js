import { MutationNames } from '../mutations/mutations'
import { chunkArray } from 'helpers/arrays.js'
import {
  Georeference,
  TaxonName,
  CollectingEvent
} from 'routes/endpoints'

const MAX_PER_CALL = 50

function getAllCollectingEvents (taxonNames) {
  return new Promise((resolve, reject) => {
    const chunks = chunkArray(Array.from(new Set(taxonNames.map(tn => tn.otus.map(otu => otu.id)).filter(id => id.length))), MAX_PER_CALL)
    const collectingEvents = []
    const promises = []

    if (chunks.length) {
      chunks.forEach(ids => {
        if (ids.length) {
          promises.push(CollectingEvent.where({ otu_id: [].concat(...ids) }).then(response => {
            collectingEvents.push(response.body)
          }))
        }
      })
    }
    Promise.all(promises).then(() => {
      const seen = new Set()
      const allCEs = [].concat(...collectingEvents)

      const uniqueCEs = allCEs.filter(el => {
        const duplicate = seen.has(el.id)
        seen.add(el.id)
        return !duplicate
      })
      resolve(Array.from(uniqueCEs))
    })
  })
}

function getAllGeoreferences(CEIds) {
  return new Promise((resolve, reject) => {
    const chunks = chunkArray(CEIds, MAX_PER_CALL)
    const georeferences = []
    const promises = []

    if (chunks.length) {
      chunks.forEach(ids => {
        promises.push(Georeference.where({ collecting_event_ids: ids }).then(response => {
          georeferences.push(response.body)
        }))
      })
    }

    Promise.all(promises).then(() => {
      resolve([].concat(...georeferences))
    })
  })
}

export default ({ commit, state }, otu) => {
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

  TaxonName.where(params).then(response => {
    descendants.taxon_names = response.body.filter(tn => tn.id !== otu.taxon_name_id)

    getAllCollectingEvents(descendants.taxon_names).then(collectingEvents => {
      descendants.collecting_events = collectingEvents
      getAllGeoreferences(collectingEvents.map(ce => ce.id)).then(georeferences => {
        state.loadState.descendantsDistribution = false
        descendants.georeferences = georeferences
        commit(MutationNames.SetDescendants, descendants)
      })
    })
  }).finally(() => {
    state.loadState.descendants = false
  })
}
