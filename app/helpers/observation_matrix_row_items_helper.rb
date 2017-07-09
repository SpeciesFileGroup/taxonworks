module ObservationMatrixRowItemsHelper
  def matrix_row_item_tag(matrix_row_item)
    return nil if matrix_row_item.nil?
    [
      matrix_tag(matrix_row_item.matrix),
      object_tag(matrix_row_item.matrix_row_item_object)
    ].compact.join(': ')
  end

  def matrix_row_item_link(matrix_row_item)
    return nil if matrix_row_item.nil?
    link_to(matrix_row_item_tag(matrix_row_item).html_safe, matrix_row_item)
  end

end
