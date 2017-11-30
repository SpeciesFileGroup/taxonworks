class ObservationMatrix < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notes
  include Shared::DataAttributes

  validates_presence_of :name

  has_many :observation_matrix_column_items, dependent: :destroy
  has_many :observation_matrix_row_items, dependent: :destroy

  has_many :observation_matrix_rows
  has_many :observation_matrix_columns

  has_many :otus, through: :observation_matrix_rows
  has_many :collection_objects, through: :observation_matrix_rows

  has_many :descriptors, through: :observation_matrix_columns

end
