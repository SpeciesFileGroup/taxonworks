export default function (objectData) {
  return {
    id: objectData.observation_object_id,
    title: objectData.object_tag,
    globalId: objectData.observation_object_global_id,
    type: objectData.observation_object_type,
    rowId: objectData.id,
    isUnsaved: false,
    needsCountdown: false,
    isSaving: false,
    hasSavedAtLeastOnce: false
  }
}
