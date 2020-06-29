import { GetTaxonNames, GetCollectingEvents, GetGeoreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { chunkArray } from 'helpers/arrays.js'

const MAX_PER_CALL = 50

function getAllCollectingEvents (taxonNames) {
  return new Promise((resolve, reject) => {
    const chunks = chunkArray(Array.from(new Set(taxonNames.map(tn => tn.otus.map(otu => otu.id)).filter(id => id.length))), MAX_PER_CALL)
    var collectingEvents = []
    var promises = []

    if (chunks.length) {
      chunks.forEach(ids => {
        if (ids.length) {
          promises.push(GetCollectingEvents([].concat(...ids)).then(response => {
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
    var georeferences = []
    var promises = []

    if (chunks.length) {
      chunks.forEach(ids => {
        promises.push(GetGeoreferences(ids).then(response => {
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
    descendants_max_depth: 2
  }
  const descendants = {
    taxon_names: [],
    collecting_events: [],
    georeferences: []
  }

  GetTaxonNames(params).then(response => {
    descendants.taxon_names = response.body.filter(tn => tn.id !== otu.taxon_name_id)
    state.loadState.descendants = false

    getAllCollectingEvents(descendants.taxon_names).then(collectingEvents => {
      descendants.collecting_events = collectingEvents
      getAllGeoreferences(collectingEvents.map(ce => ce.id)).then(georeferences => {
        descendants.georeferences = georeferences
        state.loadState.distribution = false
        commit(MutationNames.SetDescendants, descendants)
      })
    })
  })
}
