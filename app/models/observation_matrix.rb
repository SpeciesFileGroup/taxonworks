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

  def observations
    Observation.in_observation_matrix(id)
  end

  # @param descriptor: Descriptor
  # @param symbol_start: Integer  #  takes :chr => Chr, :symbol_start => Int
  # @return Hash
  #     1 => [] 
  #   used as an index method for nexml output
  # Original code in mx
  def polymorphic_cells_for_chr(options)
    opt = {symbol_start: 0}.merge!(options.to_options!)

    cells = Hash.new{|hash, key| hash[key] = Array.new}
    observations.where(descriptor_id: opt[:descriptor_id]).each do |c|
      cells[c.observation_object_global_id].push(c.chr_state_id)
    end

    foo = Hash.new{|hash, key| hash[key] = Array.new}
    i = 0
    cells.keys.each do |k|
      if foo # must be some other idiom
        if cells[k].size > 1
          foo[opt[:symbol_start] + i] = cells[k].sort 
          i += 1
        end
      end
    end
    foo
  end

end
