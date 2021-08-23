import { IDENTIFIER_LOCAL_TRIP_CODE } from 'constants/index.js'
import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeIdentifier from 'factory/Identifier.js'

export default async ({ commit }, ceId) => {
  const identifier = (await Identifier.where({
    identifier_object_type: 'CollectingEvent',
    identifier_object_id: ceId,
    type: IDENTIFIER_LOCAL_TRIP_CODE
  })).body[0] || makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent')
  commit(MutationNames.SetIdentifier, identifier)
}
