module MatrixRowItemsHelper
  def matrix_row_item_tag(matrix_row_item)
    return nil if matrix_row_item.nil?
    get_matrix_row_item_name(matrix_row_item)
  end

  def matrix_row_item_link(matrix_row_item)
    return nil if matrix_row_item.nil?
    link_to(matrix_row_item_tag(matrix_row_item).html_safe, matrix_row_item)
  end

  def get_matrix_row_item_name(matrix_row_item)
    [
      matrix_row_item.matrix, 
      matrix_row_item.otu, 
      matrix_row_item.collection_object,
      matrix_row_item.controlled_vocabulary_term
    ].compact.collect{|o| object_tag(o)}.join(":")
  end
end
