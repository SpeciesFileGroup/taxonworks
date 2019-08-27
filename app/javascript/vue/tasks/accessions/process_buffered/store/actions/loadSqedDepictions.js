import { GetDepictionByCOId } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, id) => {
  GetDepictionByCOId(id).then(response => {
    const depictions = response.body.filter(depiction => { return Object.hasOwnProperty.call(depiction, 'sqed_depiction') })
    commit(MutationNames.SetSqedDepictions, depictions)
  })
}
