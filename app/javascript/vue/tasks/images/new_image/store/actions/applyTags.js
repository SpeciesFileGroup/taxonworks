import { Tag } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, payload) => {
  const { objectType, objectIds } = payload

  const requests = state.tagsForImage.map((tag) =>
    Tag.createBatch({
      keyword_id: tag.id,
      object_id: objectIds,
      object_type: objectType
    })
  )

  return Promise.all(requests).then((_) => {
    commit(MutationNames.MarkApplied, { imageIds: objectIds, key: 'tags' })
    TW.workbench.alert.create('All tag(s) was successfully created.', 'notice')
  })
}
