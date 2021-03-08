import { GetLabelsFromCE } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import makeLabel from '../../const/makeLabel'

export default async ({ commit }, id) => {
  const label = (await GetLabelsFromCE(id)).body[0] || makeLabel()
  commit(MutationNames.SetCELabel, label)
}
