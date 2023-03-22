export default state => {
  state.edit_loan_items = state.loan_items.map(({ id, loan_item_object_type, loan_item_object_id }) =>
    ({
      id,
      loan_item_object_type,
      loan_item_object_id
    })
  )
}
