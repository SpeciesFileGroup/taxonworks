import { GetGeographicArea } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }, id = null) => {
  const geographicArea = id ? (await GetGeographicArea(id)).body : null
  if (state.collectingEvent.geographic_area_id !== geographicArea?.id) {
    commit(MutationNames.SetCollectingEvent, Object.assign({ ...state.collectingEvent }, { geographic_area_id: id }))
  }
  commit(MutationNames.SetGeographicArea, geographicArea)
}
