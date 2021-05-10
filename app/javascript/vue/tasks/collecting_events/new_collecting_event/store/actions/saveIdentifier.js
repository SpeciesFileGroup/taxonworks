import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { copyObjectByProperties } from 'helpers/objects'
import makeIdentifier from '../../const/makeTripIdentifier'

export default async ({ state: { collectingEvent, tripCode }, commit }) => {
  const newIdentifier = makeIdentifier()

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
