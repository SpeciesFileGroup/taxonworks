import { GetTripCodeByCE } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import makeTripIdentifier from '../../const/makeTripIdentifier'

export default async ({ commit }, ceId) => {
  const identifier = (await GetTripCodeByCE(ceId)).body[0] || makeTripIdentifier()
  commit(MutationNames.SetIdentifier, identifier)
}
