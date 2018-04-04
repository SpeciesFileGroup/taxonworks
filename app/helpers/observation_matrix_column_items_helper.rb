module ObservationMatrixColumnItemsHelper

  # TODO: write a meaningful name generator, requires
  # subclass instance methods(?) or subclass helper methods
  def observation_matrix_column_item_tag(observation_matrix_column_item)
    return nil if observation_matrix_column_item.nil?
    [observation_matrix_tag(observation_matrix_column_item.observation_matrix), observation_matrix_column_item.type].compact.join(': ')
  end

end
