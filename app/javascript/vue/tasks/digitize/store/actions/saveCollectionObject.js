import { CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import SetParam from '@/helpers/setParam'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'

export default ({ commit, state }, co) => {
  const store = useCollectingEventStore()
  const payload = {
    collection_object: {
      ...co,
      collecting_event_id: store.collectingEvent.id
    }
  }

  const request = co.id
    ? CollectionObject.update(co.id, payload)
    : CollectionObject.create(payload)

  request
    .then(({ body }) => {
      commit(MutationNames.SetSubsequentialUses, state.subsequentialUses + 1)
      SetParam(
        '/tasks/accessions/comprehensive',
        'collection_object_id',
        body.id
      )
    })
    .catch(() => {})

  return request
}
