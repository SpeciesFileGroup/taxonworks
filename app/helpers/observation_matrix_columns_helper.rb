module ObservationMatrixColumnsHelper

  def observation_matrix_column_tag(matrix_column)
    return nil if matrix_column.nil?
    matrix_column.descriptor.name
  end

  def observation_matrix_column_link(matrix_column)
    return nil if matrix_column.nil?
    link_to(observation_matrix_column_tag(matrix_column).html_safe, matrix_column)
  end

end
