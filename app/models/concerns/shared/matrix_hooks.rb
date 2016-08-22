# Code to update matrix content based on what goes on with this instance.
#
# Classes that include this module must implement a #matrix_column_item
# that returns a single MatrixColumnItem or false/nil.
#
module Shared::MatrixHooks

  extend ActiveSupport::Concern
  included do
    after_save :update_matrix
    after_destroy :cleaup_matrix
  end

  module ClassMethods
  end

  def update_matrix
    if matrix_column_item
      matrix_column_item.update_matrix_columns
    end

    if matrix_row_item
      matrix_row_item.update_matrix_rows
    end
  end

  def cleaup_matrix 
    if matrix_column_item
      matrix_column_item.cleanup_matrix_columns
    end

    if matrix_row_item
      matrix_row_item.cleanup_matrix_rows
    end
  end

  protected 

end
