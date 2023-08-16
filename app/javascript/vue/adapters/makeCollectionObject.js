export function makeCollectionObject (coData = {}) {
  return {
    id: coData.id,
    bufferedCollectingEvent: coData.buffered_collecting_event,
    bufferedDeterminations: coData.buffered_determinations,
    bufferedLabels: coData.buffered_other_labels,
    accesionedAt: coData.accesioned_at,
    deaccessionedAt: coData.deaccessioned_at,
    deaccessionReason: coData.deaccession_reason,
    globalId: coData.global_id,
    objectLabel: coData.objectLabel,
    objectTag: coData.object_tag,
    repositoryId: coData.repository_id,
    currentRepositoryId: coData.current_repository_id,
    total: coData.total,
    baseClass: coData.baseClass,
    preparationTypeId: coData.preparation_type_id
  }
}
