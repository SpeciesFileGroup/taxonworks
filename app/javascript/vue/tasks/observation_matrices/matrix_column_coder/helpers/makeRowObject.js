export default function (objectData) {
  return {
    id: objectData.id,
    title: objectData.object_tag,
    globalId: objectData.global_id,
    type: objectData.base_class,
    rowId: objectData.row_id,
    isUnsaved: false,
    needsCountdown: false,
    isSaving: false,
    hasSavedAtLeastOnce: false
  }
}
