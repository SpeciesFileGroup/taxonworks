# A matrix view, it defines rows and columns.
class ObservationMatrix < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes
  include Shared::DataAttributes

  validates_presence_of :name

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

end
