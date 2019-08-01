# A view to a set of observations.
# 
class ObservationMatrix < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes
  include Shared::DataAttributes

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:project_id]

  has_many :observation_matrix_column_items, dependent: :destroy, inverse_of: :observation_matrix
  has_many :observation_matrix_row_items, dependent: :destroy, inverse_of: :observation_matrix

  # TODO: restrict this, you can not directly create these
  has_many :observation_matrix_rows, inverse_of: :observation_matrix
  has_many :observation_matrix_columns, inverse_of: :observation_matrix

  # TODO: restrict this- you can not directly create these!
  has_many :otus, through: :observation_matrix_rows, inverse_of: :observation_matrices
  has_many :collection_objects, through: :observation_matrix_rows, inverse_of: :observation_matrices

  # TODO: restrict these- you can not directly create these!
  has_many :descriptors, through: :observation_matrix_columns, inverse_of: :observation_matrices

  def cell_count
    observation_matrix_rows.count * observation_matrix_columns.count 
  end

  def is_media_matrix?
    observation_matrix_columns.each do |c|
      return false unless c.descriptor.type == 'Descriptor::Media'
    end
    true
  end
    
end
