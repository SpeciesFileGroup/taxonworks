# A view to a set of Observations.
#
# @params otu_id
#   .the "parent" concept that this key applies to, for example
#   if this is species concepts it might be a species group, or genus.
#   Used primarly to index keys.
# TODO: soft validate that this OTU actually makes sense given the content of the key
#
#
class ObservationMatrix < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Documentation
  include Shared::Identifiers
  include Shared::Tags
  include Shared::Notes
  include Shared::DataAttributes
  include Shared::Attributions
  include Shared::AlternateValues
  include Shared::IsData # Hybrid of sorts, is a layout engine, but people cite matrices ...

  ALTERNATE_VALUES_FOR = [:name].freeze

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:project_id]

  # We can not inverse: `observation_matrices` as that comes from row content.
  belongs_to :otu, inverse_of: :in_scope_observation_matrices

  has_many :observation_matrix_column_items, dependent: :delete_all, inverse_of: :observation_matrix
  has_many :observation_matrix_row_items, dependent: :delete_all, inverse_of: :observation_matrix

  # TODO: restrict this, you can not directly create these
  has_many :observation_matrix_rows, inverse_of: :observation_matrix, dependent: :delete_all
  has_many :observation_matrix_columns, inverse_of: :observation_matrix, dependent: :delete_all

  # TODO: restrict this- you can not directly create these!
  # TODO: must go, define dynamically in app/models/concerns/shared/observations.rb
  has_many :otus, through: :observation_matrix_rows, inverse_of: :observation_matrices, source: :observation_object, source_type: 'Otu'
  has_many :collection_objects, through: :observation_matrix_rows, inverse_of: :observation_matrices, source: :observation_object, source_type: 'CollectionObject'
  has_many :extracts, through: :observation_matrix_rows, inverse_of: :observation_matrices, source: :observation_object, source_type: 'Extract'
  has_many :sounds, through: :observation_matrix_rows, inverse_of: :observation_matrices, source: :observation_object, source_type: 'Sound'
  has_many :field_occurrences, through: :observation_matrix_rows, inverse_of: :observation_matrices, source: :observation_object, source_type: 'FieldOccurrence'

  # TODO: restrict these- you can not directly create these!
  has_many :descriptors, -> { order('observation_matrix_columns.position') }, through: :observation_matrix_columns, inverse_of: :observation_matrices

  scope :with_otu_id_array, ->  (otu_id_array) { joins('LEFT OUTER JOIN "observation_matrix_rows" ON "observation_matrix_rows"."observation_matrix_id" = "observation_matrices"."id"').where('otu_id in (?)', otu_id_array) }

  def qualitative_descriptors
    descriptors.where(type: 'Descriptor::Qualitative').order('observation_matrix_columns.position')
  end

  def presence_absence_descriptors
    descriptors.where(type: 'Descriptor::PresenceAbsence').order('observation_matrix_columns.position')
  end

  def continuous_descriptors
    descriptors.where(type: 'Descriptor::Continuous').order('observation_matrix_columns.position')
  end

  def sample_descriptors
    descriptors.where(type: 'Descriptor::Sample').order('observation_matrix_columns.position')
  end

  def media_descriptors
    descriptors.where(type: 'Descriptor::Media').order('observation_matrix_columns.position')
  end

  def gene_descriptors
    descriptors.where(type: 'Descriptor::Gene').order('observation_matrix_columns.position')
  end

  def working_descriptors
    descriptors.where(type: 'Descriptor::Working').order('observation_matrix_columns.position')
  end

  # As handled in export/parsing by external tools
  # !! Note order() is applied !!
  def symbol_descriptors
    descriptors.where(type: ['Descriptor::PresenceAbsence', 'Descriptor::Qualitative']).order('observation_matrix_columns.position')
  end

  def character_states
    CharacterState.joins(descriptor: [:observation_matrices]).merge(descriptors)
  end

  # TODO: helper method
  def cell_count
    observation_matrix_rows.count * observation_matrix_columns.count
  end

  # @return True if every descriptor is a media descriptor
  def is_media_matrix?
    observation_matrix_columns.each do |c|
      return false unless c.descriptor.type == 'Descriptor::Media'
    end
    true
  end

  #@return [Boolean]
  #   reorders all rows and returns true or false
  def reorder_rows(by = 'reindex')
    case by
    when 'reindex'
      observation_matrix_rows.order('observation_matrix_rows.position').each.with_index do |r,i|
        r.update_column(:position, i)
      end
    when 'nomenclature'
      objects = []
      observation_matrix_rows.each do |r|
        t = r.current_taxon_name # not all rows have reference to a taxon name
        objects.push [r, (t ? TaxonName.self_and_ancestors_of(t).order('taxon_name_hierarchies.generations DESC').pluck(:name).to_s : '')]
      end

      objects.sort!{|a, b| a[1] <=> b[1]} # add internal loop on name
      objects.each_with_index do |r,i|
        r[0].update_column(:position, i)
      end
    else
      return false
    end
    true
  end

  def reorder_columns(by = 'reindex')
    case by
    when 'reindex'
      observation_matrix_columns.order('observation_matrix_columns.position').each.with_index do |c,i|
        c.update_column(:position, i)
      end
    when 'name'
      observation_matrix_columns.order('descriptors.name').each.with_index do |c,i|
        c.update_column(:position, i)
      end
    else
      return false
    end
    true
  end

  def observations
    Observation.in_observation_matrix(id)
  end

  def media_observations
    Observation::Media.in_observation_matrix(id)
  end

  # TODO: Railsify
  def observation_depictions
    Depiction.select('depictions.*, observations.descriptor_id, observations.observation_object_id, observations.observation_object_type, sources.id AS source_id, sources.cached_author_string, sources.year, sources.cached AS source_cached')
      .joins('INNER JOIN observations ON observations.id = depictions.depiction_object_id')
      .joins('INNER JOIN images ON depictions.image_id = images.id')
      .joins("LEFT OUTER JOIN citations ON citations.citation_object_id = images.id AND citations.citation_object_type = 'Image' AND citations.is_original IS TRUE")
      .joins('LEFT OUTER JOIN sources ON citations.source_id = sources.id')
      .where(depiction_object: media_observations).order('depictions.position')
  end

  # @return [Hash]
  #   grid: [columns][rows][observations]
  #
  # Note: old mx version had additional, at present not needed, they can be added via the row/column_index to get:
  #   rows: [Otu1, Otu2... CollectonObject1]  (was a global ID in mx)
  #   columns: [descriptor.id, desriptor.id]
  #
  # !! :position attribute starts at 1
  # !! Grid starts at 0 !!
  def observations_in_grid(options = {})
    opts = {
      row_start:  1,
      row_end: 'all',
      col_start: 1,
      col_end: 'all',
      row_index: false,
      column_index: false,
    }.merge!(options.symbolize_keys)

    return false if (opts[:row_start] == 0) || (opts[:col_start] == 0) # catch problems with forgetting index starts at 1

    grid = empty_grid(opts)

    reindex_row_order if observation_matrix_rows.first.position != 1 || (observation_matrix_rows.last.position != observation_matrix_rows.size)
    reindex_column_order if observation_matrix_columns.first.position != 1 || (observation_matrix_columns.last.position != observation_matrix_columns.size)

    # Dump the observations into bins
    obs = Observation.by_matrix_and_position(self.id, opts)
      .select('omc.position as column_index, omr.position as row_index, observations.*')

    rows, cols = [], []

    obs.each do |o|
      grid[o.column_index - 1][o.row_index - 1].push(o)

      # These might not ever be needed, they were used in MX
      if opts[:row_index]
        rows[o.row_index - 1] = o.observation_object_type + o.observation_object_id.to_s if rows[o.row_index - 1].nil?
      end

      if opts[:column_index]
        cols[o.column_index - 1] = o.descriptor_id if cols[o.column_index - 1].nil?
      end
    end

    {grid:, rows:, cols:}
  end

  def reindex_row_order
    i = 1
    observation_matrix_rows.order(:position).find_each do |o|
      o.update_column(:position, i)
      i += 1
    end
    true
  end

  def reindex_column_order
    i = 1
    observation_matrix_columns.order(:position).find_each do |o|
      o.update_column(:position, i)
      i += 1
    end
    true
  end

  # @return [Array]
  def empty_grid(opts)
    re = if opts[:row_end] == 'all'
           observation_matrix_rows.count + 1
         else
           opts[:row_end]
         end

    ce = if opts[:col_end] == 'all'
           observation_matrix_columns.count + 1
         else
           opts[:col_end]
         end

    Array.new(ce - opts[:col_start]){Array.new(re - opts[:row_start]){Array.new}}
  end

  # @param descriptor_id [Descriptor]
  # @param symbol_start [Integer]  #  takes :chr => Chr, :symbol_start => Int
  # @return Hash
  #     1 => [character_state.id, charater_state.id]
  #   Used soley as a indexing method for nexml output
  # Original code in mx
  def polymorphic_cells_for_descriptor(symbol_start: 0, descriptor_id:)
    symbol_start ||= 0
    cells = Hash.new{|hash, key| hash[key] = Array.new}
    observations.where(descriptor_id:).each do |o|
      g = "#{o.observation_object_type}|#{o.observation_object_id}"
      cells[g].push(
        o.qualitative? ? o.character_state_id : "#{o.descriptor_id}_#{o.presence_absence? ? '1' : '0'}"
      )
    end

    r = Hash.new{|hash, key| hash[key] = Array.new}
    i = 0
    cells.keys.each do |k|
      if r # must be some other idiom
        if cells[k].size > 1
          r[symbol_start + i] = cells[k].sort
          i += 1
        end
      end
    end
    r
  end

  # @return [Hash]
  #  a hash of hashes of arrays with the coding objects nicely organized
  #   descriptor_id1 =>{ "Otu1" => [observation1, observation2], descriptor_id: nil}
  #
  #  was `codings_mx` in mx where this: "likely should add scope and merge with above, though this seems to be slower"
  def observations_hash
    h = Hash.new{|hash, key| hash[key] = Hash.new{|hash2, key2| hash2[key2] = Array.new}}
    observations.each {|o| h[o.descriptor_id][o.observation_object_type + o.observation_object_id.to_s].push(o) }
    #observations.each {|o| h[o.descriptor_id][o.observation_object_global_id].push(o) } ### potentially useful but extra compute slower
    h
  end

  def batch_populate(params)
    queries = params.keys.select{|a| a =~ /_query/ }
    return false if queries.size != 1

    result = {
      rows: 0,
      columns: 0,
      observation_matrix_id: id,
      observation_matrix_name: name
    }

    descriptors = []
    observables = []

    case queries[0]
    when 'descriptor_query'
      descriptors = ::Queries::Descriptor::Filter.new(params[:descriptor_query]).all

    when 'observation_query'
      descriptors = ::Queries::Descriptor::Filter.new(observation_query: params[:observation_query]).all

      OBSERVABLE_TYPES.each do |t|
        f = "::Queries::#{t}::Filter".safe_constantize
        next if f.nil? || !f.method_defined?(:observation_query_facet)

        observables += f.new(observation_query: params[:observation_query]).all
      end

    else # Rows (observables) only
      query_klass = queries[0].delete_suffix('_query').camelize
      f = "::Queries::#{query_klass}::Filter".safe_constantize
      return result if f.nil? || !OBSERVABLE_TYPES.include?(query_klass)

      observables = f.new(params[queries[0]]).all
    end

    observables.each do |o|
      # Fail silently
      j = ObservationMatrixRowItem::Single.create(observation_matrix: self, observation_object: o)
      result[:rows] += 1 if j.persisted?
    end

    descriptors.each do |d|
      j = ObservationMatrixColumnItem::Single::Descriptor.create(observation_matrix: self, descriptor: d)
      result[:columns] += 1 if j.persisted?
    end

    result
  end

  def self.batch_add(params)
    return false if params[:observation_matrix_id].blank?
    o = ObservationMatrix.find_by(project_id: params[:project_id], id: params[:observation_matrix_id])
    o.batch_populate(params)
  end

  def self.batch_create(params)
    o = ObservationMatrix.create(params.require(:observation_matrix).permit(:name))
    if o.persisted?
      o.batch_populate(params)
    else
      o.errors.full_messages
    end
  end

end
