import { GeographicArea } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }, id = null) => {
  const geographicArea = id ? (await GeographicArea.find(id, { geo_json: true })).body : null
  if (state.collectingEvent.geographic_area_id !== geographicArea?.id) {
    commit(MutationNames.SetCollectingEvent, Object.assign({ ...state.collectingEvent }, { geographic_area_id: id }))
  }
  commit(MutationNames.SetGeographicArea, geographicArea)
}
