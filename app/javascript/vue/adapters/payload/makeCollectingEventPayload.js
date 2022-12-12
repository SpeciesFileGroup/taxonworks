export function makeCollectionObjectPayload (coData) {
  return {
    id: coData.id,
    buffered_collecting_event: coData.bufferedCollectingEvent,
    buffered_determinations: coData.bufferedDeterminations,
    buffered_other_labels: coData.bufferedLabels,
    accesioned_at: coData.accesionedAt,
    deaccessioned_at: coData.deaccessionedAt,
    deaccession_reason: coData.deaccessionReason,
    repository_id: coData.repositoryId,
    current_repository_id: coData.currentRepositoryId,
    total: coData.total,
    preparation_type_id: coData.preparationTypeId
  }
}
