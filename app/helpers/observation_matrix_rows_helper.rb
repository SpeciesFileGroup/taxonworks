module ObservationMatrixRowsHelper

  def observation_matrix_row_tag(matrix_row)
    return nil if matrix_row.nil?
    get_matrix_row_name(matrix_row)
  end

  def observation_matrix_row_link(matrix_row)
    return nil if matrix_row.nil?
    link_to(observation_matrix_row_tag(matrix_row).html_safe, matrix_row)
  end

  def get_matrix_row_name(matrix_row)
    object_tag(matrix_row.row_object)
  end
end
