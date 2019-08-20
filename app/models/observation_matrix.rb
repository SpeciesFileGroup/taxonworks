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

  # ex mx
  # this could definitely be optimized
  # position is from 1 but grid is from 0 !!
  # optimize by 
  # - returning only codings within Otu range, not just Chr range
  def codings_in_grid(options = {})
    opts = {
      row_start:  1,
      row_end: 'all',
      col_start: 1,
      col_end: 'all'
    }.merge!(options.symbolize_keys)

    return false if (opts[:row_start] == 0) || (opts[:col_start] == 0) # catch problems with forgetting index starts at 1

    rows = []  # y axis
    cols = []  # x axis
    r = []
    c = []
    if opts[:row_end] == 'all'
      r = observation_matrix_rows
    else
      r = observation_matrix_rows.where("observation_matrix_rows.position >= ? and observation_matrix_rows.position <= ?", opts[:row_start], opts[:row_end])
    end
    return false if rows.size == 0
    rows = r.collect{|o| o.to_global_id.to_s} # should be object, not row

    if opts[:col_end] == 'all'
      c = descriptors.order(:position)
    else
      c = observation_matrix_rows.where("observation_matrix_columns.position >= ? and observation_matrix_columns.position <= ?", opts[:col_start], opts[:col_end])  #self.chrs.within_mx_range(opts[:chr_start], opts[:chr_end])
    end

    cols = c.collect{|c| c.id} # global id ?
    return false if cols.size == 0

    # three dimensional array
    grid = Array.new(cols.size){Array.new(rows.size){Array.new}}
   
    Observation.where(descriptor_id: cols,   "chr_id in (#{chrs.join(",")}) AND otu_id in (#{otus.join(",")})").each do |c|    
    
      Coding.find(:all, :conditions => "chr_id in (#{chrs.join(",")}) AND otu_id in (#{otus.join(",")})").each do |c|    
        if otus.index(c.otu_id)
          grid[chrs.index(c.chr_id)][otus.index(c.otu_id)].push(c) 
        end
    end
    
    {grid: grid, chrs: @c, otus: @o }
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
