export default state => {
  state.collection_object = {
    id: undefined,
    global_id: undefined,
    total: 1,
    repository_id: undefined,
    ranged_lot_category_id: undefined,
    collecting_event_id: undefined,
    buffered_collecting_event: state.locked.buffered_collecting_event ? state.collection_object.buffered_collecting_event : undefined,
    buffered_determinations: state.locked.buffered_determination ? state.collection_object.buffered_determinations : undefined,
    buffered_other_labels: state.locked.buffered_other_labels ? state.collection_object.buffered_other_labels : undefined,
    deaccessioned_at: undefined,
    deaccession_reason: undefined,
    contained_in: undefined
  }
}
