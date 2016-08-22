# Code to update matrix content based on what goes on with this instance.
#
# Classes that include this module must implement
#   matrix_column_item
#   matrix_row_item
# that returns a single hash containing the matrix_column/row_item and its descriptor/object or false/nil.
# eg {"matrix_column_item": matrix_column_item, "descriptor": descriptor}, or false
# eg {"matrix_row_item": matrix_row_item, "object": object}, or false
module Shared::MatrixHooks

  extend ActiveSupport::Concern
  included do
    after_save :update_matrix
    after_destroy :cleanup_matrix
  end

  module ClassMethods
  end

  def update_matrix
    if matrix_column_item
      mci = matrix_column_item[:matrix_column_item]
      descriptor = matrix_column_item[:descriptor]

      mci.update_single_matrix_column(descriptor)
    end

    if matrix_row_item
      mri = matrix_row_item[:matrix_row_item]
      object = matrix_row_item[:object]

      mri.update_single_matrix_row(object)
    end
  end

  def cleanup_matrix 
    if matrix_column_item
      mci = matrix_column_item[:matrix_column_item]
      descriptor = matrix_column_item[:descriptor]

      mci.cleanup_single_matrix_column(descriptor.id)
    end

    if matrix_row_item
      mri = matrix_row_item[:matrix_row_item]
      object = matrix_row_item[:object]

      mri.cleanup_single_matrix_row(object)
    end
  end

  protected 

end
