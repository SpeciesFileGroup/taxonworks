import { GeographicArea } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }, id = null) => {
  const geographicArea = id
    ? (await GeographicArea.find(id, { embed: ['shape'] })).body
    : null

  if (state.collectingEvent.geographic_area_id !== geographicArea?.id) {
    commit(MutationNames.SetCollectingEvent, { ...state.collectingEvent, geographic_area_id: id })
  }

  if (!id) {
    state.collectingEvent.meta_prioritize_geographic_area = null
  }

  commit(MutationNames.SetGeographicArea, geographicArea)
}
