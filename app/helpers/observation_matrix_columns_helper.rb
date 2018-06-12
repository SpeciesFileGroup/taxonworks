module ObservationMatrixColumnsHelper

  def observation_matrix_column_tag(matrix_column)
    return nil if matrix_column.nil?
    matrix_column.descriptor.name
  end

  def observation_matrix_column_link(matrix_column)
    return nil if matrix_column.nil?
    link_to(observation_matrix_column_tag(matrix_column).html_safe, matrix_column)
  end


  # @return [Id, nil]
  #   if destroyable (represented by only a single OMRI of type Single) then return the ID
  def observation_matrix_column_destroyable?(observation_matrix_column)
    if !observation_matrix_column.cached_observation_matrix_column_item_id.blank?
      return observation_matrix_column.id if observation_matrix_column.reference_count == 1
    end
    nil
  end

end
