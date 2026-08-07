export default (state) =>
  ({ id, type }) => {
    return state.relatedBAs.filter(
      (item) =>
        (item.biological_association_object_id === id &&
          item.biological_association_object_type === type) ||
        (item.biological_association_subject_id === id &&
          item.biological_association_subject_type === type)
    )
  }
