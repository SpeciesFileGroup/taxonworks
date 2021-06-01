import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeTripIdentifier from '../../const/makeTripIdentifier'

export default async ({ commit }, ceId) => {
  const identifier = (await Identifier.where({
    identifier_object_type: 'CollectingEvent',
    identifier_object_id: ceId,
    type: 'Identifier::Local::TripCode'
  })).body[0] || makeTripIdentifier()
  commit(MutationNames.SetIdentifier, identifier)
}
