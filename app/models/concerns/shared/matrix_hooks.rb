# Code to update matrix content based on what goes on with this instance.
#
# Classes that include this module must implement a #matrix_column_item
# that returns a single MatrixColumnItem or false/nil.
#
module Shared::MatrixHooks

  extend ActiveSupport::Concern
  included do
    after_save :update_matrix_columns, if: :matrix_column_item
    after_destroy :cleanup_matrix_columns, if: :matrix_column_item
  end

  module ClassMethods
  end

  def update_matrix_columns
    if matrix_column_item
      matrix_column_item.update_matrix_columns 
    end
    true
  end

  def cleanup_matrix_columns
    if matrix_column_item
      matrix_column_item.cleanup_matrix_columns 
    end
    true 
  end

  protected 

end
