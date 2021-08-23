import { IDENTIFIER_LOCAL_TRIP_CODE } from 'constants/index.js'
import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { copyObjectByProperties } from 'helpers/objects'
import makeIdentifier from 'factory/Identifier.js'

export default async ({ state: { collectingEvent, tripCode }, commit }) => {
  const newIdentifier = makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent')

  if (tripCode.namespace_id && tripCode.identifier) {
    const data = copyObjectByProperties(tripCode, newIdentifier)

    data.identifier_object_id = collectingEvent.id
    return (data.id
      ? Identifier.update(data.id, { identifier: data })
      : Identifier.create({ identifier: data })
    ).then(response => {
      commit(MutationNames.SetIdentifier, response.body)
    })
  }
}
