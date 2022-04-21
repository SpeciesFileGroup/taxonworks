import { Tag } from 'routes/endpoints'

export default ({ state }, payload) => {
  const {
    objectType,
    objectIds
  } = payload

  const requests = state.tagsForImage.map(tag =>
    Tag.createBatch({
      keyword_id: tag.id,
      object_ids: objectIds,
      object_type: objectType
    })
  )

  Promise.all(requests).then(_ => {
    TW.workbench.alert.create('All tag(s) was successfully created.', 'notice')
  })
}
