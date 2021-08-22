import { MutationNames } from '../mutations/mutations'
import { CollectingEvent } from 'routes/endpoints'
import makeIdentifierCE from '../../const/identifierCE'

export default ({ commit }, id) =>
  CollectingEvent.find(id).then(({ body }) => {
    commit(MutationNames.SetCollectingEvent, body)
    commit(MutationNames.SetCollectingEventIdentifier, body.identifiers[0] || makeIdentifierCE())
  })
