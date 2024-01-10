import { CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import SetParam from '@/helpers/setParam'

export default ({ commit, state }, co) => {
  const payload = {
    collection_object: {
      ...co,
      collecting_event_id: state.collecting_event.id
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
