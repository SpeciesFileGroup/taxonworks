module MatrixRowsHelper

  def matrix_row_tag(matrix_row)
    return nil if matrix_row.nil?
    get_matrix_row_name(matrix_row)
  end

  def matrix_row_link(matrix_row)
    return nil if matrix_row.nil?
    link_to(matrix_row_tag(matrix_row).html_safe, matrix_row)
  end

  def get_matrix_row_name(matrix_row)
    [matrix_row.matrix, matrix_row.otu, matrix_row.collection_object].compact.collect{|o| object_tag(o)}.join(":")
  end
end