module MatrixColumnItemsHelper

  # TODO: write a meaningful name generator, requires
  # subclass instance methods(?) or subclass helper methods
  def matrix_column_item_tag(matrix_column_item)
    return nil if matrix_column_item.nil?
    [matrix_tag(matrix_column_item.matrix), matrix_column_item.type].compact.join(': ')
  end

end
