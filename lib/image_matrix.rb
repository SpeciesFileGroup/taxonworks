# Contains methods used to build an image_matrix table
class ImageMatrix

  ##### FILTER PARAMETERS #####

  # @!observation_matrix_id
  #   @return [String]
  # Required attribude to build the key
  attr_accessor :observation_matrix_id

  # @!project_id
  #   @return [String]
  # Required attribute to build the key
  attr_accessor :project_id

  # @!language_id
  #   @return [String or null]
  # Optional attribute to display the descriptors and character_states in a particular language (when translations are available)
  attr_accessor :language_id

  # @!keyword_ids
  #   @return [String or null]
  # Optional attribute to provide a list of tagIDs to limit the set of descriptors to those taged: "keyword_ids=1|5|15"
  attr_accessor :keyword_ids

  # @!row_filter
  #   @return [String or null]
  # Optional attribute to provide a list of rowIDs to limit the set "row_filter=1|5|10"
  attr_accessor :row_filter

  # @!otu_filter
  #   @return [String or null]
  # Optional attribute to provide a list of rowIDs to limit the set "otu_filter=1|5|10"
  attr_accessor :otu_filter

  # @!eliminate_unknown
  #   @return [Boolean or null]
  # Optional attribute to eliminate taxa with no scores on a used descriptor: 'false' - default or 'true'
  # If true, the rows without scores will be eliminated
  attr_accessor :eliminate_unknown

  # @!identified_to_rank
  #   @return [String or null]
  # Optional attribute to limit identification to OTU or a particular nomenclatural rank. Valid values are 'otu', 'species', 'genus', etc.
  attr_accessor :identified_to_rank

  ##### RETURNED DATA ######

  # @!observation_matrix
  #   @return [Object]
  # Returns observation_matrix as an object
  attr_accessor :observation_matrix

  # @!observation_matrix_citation
  #   @return [Object]
  # Returns observation_matrix_citation as an object
  attr_accessor :observation_matrix_citation

  # @!descriptors
  #   @return [null]
  # Temporary attribute. Used for validation.
  attr_accessor :descriptors

  # @!descriptor_available_keywords
  #   @return [Array of Objects or null]
  # Returns the list of all Tags used with the descriptors. Descriptors could be filtered by tag_id
  attr_accessor :descriptor_available_keywords

  # @!language_to_use
  #   @return [Object or null]
  # Returns Language as an object if the language_id was provided (used to display descriptors in a particular language)
  attr_accessor :language_to_use

  # @!descriptors_with_filter
  #   @return [null]
  # Temporary attribute. Used for validation. List of descriptors reduced by keyword_ids
  attr_accessor :descriptors_with_filter

  # @!descriptor_available_languages
  #   @return [Array of Objects or null]
  # Returns the list of available Languages used as translations for descriptors (in translations are available)
  attr_accessor :descriptor_available_languages

  # @!rows_with_filter
  #   @return [null]
  # Temporary attribute. Used for validation. list of rows to be included into the matrix
  attr_accessor :rows_with_filter

  # @!row_id_filter_array
  #   @return [array]
  # Array of row_ids in the @row_filter
  attr_accessor :row_id_filter_array

  # @!otu_id_filter_array
  #   @return [array]
  # Array of otu_ids in the @otu_filter
  attr_accessor :otu_id_filter_array

  # @!list_of_descriptors
  #   @return [Array]
  # Return the list of descriptors and their states. Translated (if needed) and Sorted
  attr_accessor :list_of_descriptors

  # @!depiction_matrix
  #   @return [Hash of Arrays]
  # Returns the table of observations with images.
  attr_accessor :depiction_matrix

  # @!image_hash
  #   @return [Hash]
  # Returns the hash with image attributes
  attr_accessor :image_hash

  # @!row_hash
  #   @return [null]
  # Temporary hash of rows; used for calculation of remaining and eliminated rows
  attr_accessor :row_hash

  # @!descriptors_hash
  #   @return [null]
  #temporary hash of descriptors; used for calculation of useful and not useful descriptors and their states
  attr_accessor :descriptors_hash

  def initialize(
      observation_matrix_id: nil,
      project_id: nil,
      language_id: nil,
      keyword_ids: nil,
      row_filter: nil,
      otu_filter: nil,
      identified_to_rank: nil)

    @observation_matrix_id = observation_matrix_id
    @project_id = project_id
    @observation_matrix = find_observation_matrix
    @observation_matrix_citation = @observation_matrix&.source
    @language_id = language_id
    @keyword_ids = keyword_ids
    @descriptor_available_keywords = descriptor_available_keywords
    @row_filter = row_filter
    @otu_filter = otu_filter
    @row_id_filter_array = row_filter_array
    @otu_id_filter_array = otu_filter_array
    @rows_with_filter = get_rows_with_filter
    @identified_to_rank = identified_to_rank
    @row_hash = row_hash_initiate
    @descriptors_with_filter = descriptors_with_keywords
    @descriptor_available_languages = descriptor_available_languages_list
    @language_to_use = language_to_use
    ###main_logic
    @list_of_descriptors = build_list_of_descriptors
    @depiction_matrix = descriptors_hash_initiate
    @image_hash = build_image_hash
    ###delete temporary data
    @row_hash = nil
    @rows_with_filter = []
    @descriptors_with_filter = nil
  end

  def find_observation_matrix
    ObservationMatrix.where(id: @observation_matrix_id.to_i, project_id: @project_id).first
  end

  def descriptors
    return nil if @observation_matrix.nil?
    @observation_matrix.descriptors.where("descriptors.type = 'Descriptor::Media'").not_weight_zero
  end

  def descriptor_available_languages_list
    return nil if @descriptors_with_filter.nil?
    descriptor_ids = @descriptors_with_filter.collect{|i| i.id}
    languages = Language.joins(:alternate_value_translations)
                    .where(alternate_values: {alternate_value_object_type: 'Descriptor', type: 'AlternateValue::Translation'})
                    .where('alternate_values.alternate_value_object_id IN (?)', descriptor_ids ).order('languages.english_name').distinct.to_a
    unless languages.empty?
      languages = Language.where(english_name: 'English').to_a + languages
    end
    languages
  end

  def language_to_use
    return nil if @language_id.blank?
    l = Language.where(id: @language_id).first
    return nil if l.nil? || !@descriptor_available_languages.to_a.include?(l)
    l
  end

  def descriptor_available_keywords
    return nil if descriptors.nil?
    descriptor_ids = descriptors.pluck(:id)
    tags = Keyword.joins(:tags)
               .where(tags: {tag_object_type: 'Descriptor'})
               .where('tags.tag_object_id IN (?)', descriptor_ids ).order('name').distinct.to_a
  end

  def descriptors_with_keywords
    if @observation_matrix_id.to_i == 0 && !@otu_filter.blank?
      d = observation_depictions_from_otu_filter.pluck(:descriptor_id).uniq
      ds = Descriptor.where("descriptors.type = 'Descriptor::Media' AND descriptors.id IN (?)", d).not_weight_zero
    elsif @keyword_ids
      ds = descriptors.joins(:tags).where('tags.keyword_id IN (?)', @keyword_ids.to_s.split('|').map(&:to_i) )
    else
      ds = descriptors
    end
    return [] if ds.nil? || ds.empty?
    ds = ds.sort{|a,b| a.observation_matrix_columns.first.try(:position).to_i <=> b.observation_matrix_columns.first.try(:position).to_i}
    ds
  end

  def row_filter_array
    @row_filter.blank? ? nil : row_filter.to_s.split('|').map(&:to_i)
  end

  def otu_filter_array
    @otu_filter.blank? ? nil : otu_filter.to_s.split('|').map(&:to_i)
  end

  def get_rows_with_filter
    return [] if @observation_matrix.nil?
    @observation_matrix.observation_matrix_rows.order(:position)
  end

  def row_hash_initiate
    h = {}
    if @observation_matrix_id.to_i == 0 && !@otu_filter.blank?
      o = observation_depictions_from_otu_filter.pluck(:otu_id).uniq
      @otu_id_filter_array = @otu_id_filter_array & o
      rows = Otu.where('otus.id IN (?)', @otu_id_filter_array)
    else
      rows = @rows_with_filter
    end
    rows.each do |r|
      case r.class.to_s
        when 'Otu'
          otu_collection_object = r.id.to_s + '|'
        when 'ObservationMatrixRow'
          otu_collection_object = r.otu_id.to_s + '|' + r.collection_object_id.to_s
      end
      h[otu_collection_object] = {}
      h[otu_collection_object][:object] = r

      if @identified_to_rank == 'otu'
        case r.class.to_s
        when 'Otu'
          h[otu_collection_object][:object_at_rank] = r
        when 'ObservationMatrixRow'
          h[otu_collection_object][:object_at_rank] = r.current_otu || r
        end
      elsif @identified_to_rank
        case r.class.to_s
        when 'Otu'
          h[otu_collection_object][:object_at_rank] = r&.taxon_name&.valid_taxon_name&.ancestor_at_rank(@identified_to_rank, inlude_self = true) || r
        when 'ObservationMatrixRow'
          h[otu_collection_object][:object_at_rank] = r&.current_taxon_name&.ancestor_at_rank(@identified_to_rank, inlude_self = true) || r
        end
      else
        h[otu_collection_object][:object_at_rank] = r
      end
      h[otu_collection_object][:otu_id] = r.class.to_s == 'Otu' ? r.id : r.otu_id
    end
    h
  end

  ## descriptors_hash: {descriptor.id: {:descriptor,           ### (descriptor)
  ##                                    :observations,         ### (array of observations for )
  ##                                    :state_ids,            ### {hash of state_ids used in the particular matrix}
  ##                                    }}
  def descriptors_hash_initiate
    h = {}
    if @observation_matrix_id.to_i == 0 && !@otu_filter.blank?
      depictions = observation_depictions_from_otu_filter
    else
      depictions = @observation_matrix.observation_depictions
    end
    descriptors_count = @list_of_descriptors.count
    @row_hash.each do |r_key, r_value|
      if (@row_id_filter_array.nil? && @otu_id_filter_array.nil?) ||
          (@row_id_filter_array && @row_id_filter_array.include?(r_value[:object].id)) ||
          (@otu_id_filter_array && @otu_id_filter_array.include?(r_value[:otu_id]))
        h[r_key] = {object: r_value[:object_at_rank],
                    row_id: r_value[:object].id,
                    depictions: Array.new(descriptors_count) {Array.new},
                    } if h[r_key].nil?
      end
    end

    depictions.each do |o|
      next if @otu_id_filter_array && !@otu_id_filter_array.include?(o.otu_id)
      otu_collection_object = o.otu_id.to_s + '|' + o.collection_object_id.to_s
      if h[otu_collection_object]
        descriptor_index = @list_of_descriptors[o.descriptor_id][:index]
        h[otu_collection_object][:depictions][descriptor_index] += [o]
      end
    end
    h
  end

  def observation_depictions_from_otu_filter
      Depiction.select('depictions.*, observations.descriptor_id, observations.otu_id, observations.collection_object_id, sources.id AS source_id, sources.cached_author_string, sources.year, sources.cached AS source_cached')
          .joins("INNER JOIN observations ON observations.id = depictions.depiction_object_id")
          .joins("INNER JOIN images ON depictions.image_id = images.id")
          .joins("LEFT OUTER JOIN citations ON citations.citation_object_id = images.id AND citations.citation_object_type = 'Image' AND citations.is_original IS TRUE")
          .joins("LEFT OUTER JOIN sources ON citations.source_id = sources.id")
          .where("observations.type = 'Observation::Media' AND observations.otu_id IN (?)", @otu_id_filter_array)
          .where('observations.project_id = (?)', @project_id)
          .order('depictions.position')
  end

  # returns {123: ['1', '3'], 125: ['3', '5'], 135: ['2'], 136: ['true'], 140: ['5-10']}
  def selected_descriptors_hash_initiate
    # "123:1|3||125:3|5||135:2"
    h = {}
    return h if @selected_descriptors.blank?
    a = @selected_descriptors.include?('||') ? @selected_descriptors.to_s.split('||') : [@selected_descriptors]
    a.each do |i|
      d = i.split(':')
      h[d[0].to_i] = d[1].include?('|') ? d[1].split('|') : [d[1]]
    end
    h
  end

  def build_list_of_descriptors
    language = @language_id.blank? ? nil : @language_id.to_i
    n = 0
    h = {}
    @descriptors_with_filter.each do |d|
      descriptor = {}
      descriptor[:index] = n
      descriptor[:id] = d.id
      descriptor[:type] = d.type
      descriptor[:name] = d.target_name(:key, language)
      descriptor[:weight] = d.weight
      descriptor[:description] = d.description
      h[d.id] = descriptor
      n += 1
    end
    h
  end

  def build_image_hash
    if @observation_matrix_id.to_i == 0 && !@otu_filter.blank?
      img_ids = observation_depictions_from_otu_filter.pluck(:image_id).uniq
    else
      img_ids = @observation_matrix.observation_depictions.pluck(:image_id).uniq
    end
    imgs = Image.where('id IN (?)', img_ids )
    h = {}
    imgs.each do |d|
      i = {}
      i[:global_id] = d.to_global_id.to_s
      i[:image_file_file_name] = d.image_file_file_name
      i[:image_file_file_size] = d.image_file_file_size
      i[:image_file_content_type] = d.image_file_content_type
      i[:user_file_name] = d.user_file_name
      i[:height] = d.height
      i[:width] = d.width
      i[:original_url] = d.image_file.url
      i[:medium_url] = d.image_file.url(:medium)
      i[:thumb_url] = d.image_file.url(:thumb)
      h[d.id] = i
    end
    h
  end

end


