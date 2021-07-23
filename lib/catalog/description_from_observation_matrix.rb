# Contains methods used to build an otu description from the matrix

# http://localhost:3000/tasks/observation_matrices/description_from_observation_matrix/description?otu_id=45291&observation_matrix_id=24
#
class Catalog::DescriptionFromObservationMatrix

  ##### FILTER PARAMETERS #####

  # @!observation_matrix_id
  #   @return [String]
  # Optional attribude to build the description
  attr_accessor :observation_matrix_id

  # @!include_descendants
  #   @return [Boolean]
  # Optional attribude to include descentant otus and collection_objects
  attr_accessor :include_descendants

  # @!project_id
  #   @return [String]
  # Required attribute to build the key
  attr_accessor :project_id

  # @!language_id
  #   @return [String or null]
  # Optional attribute to display the descriptors and character_states in a particular language (when translations are available)
  attr_accessor :language_id

  # @!observation_matrix_row_id
  #   @return [String or null]
  # Optional attribute to provide a rowID
  attr_accessor :observation_matrix_row_id

  # @!otu_id
  #   @return [String or null]
  # Optional attribute to provide a otuID
  attr_accessor :otu_id

  ##### RETURNED DATA ######

  # @!observation_matrix
  #   @return [Object]
  # Returns observation_matrix as an object
  attr_accessor :observation_matrix

  # @!descriptor_available_languages
  #   @return [Array of Objects or null]
  # Returns the list of available Languages used as translations for descriptors and character_states (in translations are available)
  attr_accessor :descriptor_available_languages

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

  # @!otu_id_filter_array
  #   @return [array]
  # Array of otu_ids in the @otu_filter
  attr_accessor :otu_id_filter_array

  # @!collection_object_id_filter_array
  #   @return [array]
  # Array of collection_object_ids
  attr_accessor :collection_object_id_filter_array

  # @!similar_objects
  #   @return [hash]
  # Hash of similar otus_ids and collection_objects_ids
  attr_accessor :similar_objects

  # @!collection_object_ids_count_hash
  #   @return [hash]
  # Hash of similar collection_objects
  attr_accessor :collection_object_ids_count_hash


  # @!descriptor_hash
  #   @return [hash]
  # Temporary attribute. Used to generated description and diagnosis
  attr_accessor :descriptor_hash

  # @!generated_description
  #   @return [string]
  # Returns generated description for OTU
  attr_accessor :generated_description

  # @!generated_diagnosis
  #   @return [string]
  # Returns generated diagnosis for OTU
  attr_accessor :generated_diagnosis

  def initialize(
    observation_matrix_id: nil,
    project_id: nil,
    include_descendants: nil,
    language_id: nil,
    keyword_ids: nil,
    observation_matrix_row_id: nil,
    otu_id: nil,
    similar_objects: [])

    # raise if observation_matrix_id.blank? || project_id.blank?
    @observation_matrix_id = observation_matrix_id
    @project_id = project_id
    @observation_matrix_row_id = observation_matrix_row_id
    @observation_matrix = find_matrix
    @include_descendants = include_descendants
    @language_to_use = language_to_use
    @descriptor_available_keywords = descriptor_available_keywords
    @descriptors_with_filter = descriptors_with_keywords
    @descriptor_available_languages = descriptor_available_languages
    @language_id = language_id
    @otu_id = otu_id
    @otu_id_filter_array = otu_id_array
    @collection_object_id_filter_array = collection_object_id_array
    ###main_logic
    @descriptor_hash = get_descriptor_hash
    @generated_description = get_description
    @generated_diagnosis = get_diagnosis
    ###delete temporary data
    @descriptors_with_filter = nil
    @descriptor_hash = nil
  end

  def find_matrix
    return nil if (@observation_matrix_id.blank? || @observation_matrix_id.to_s == '0') && @observation_matrix_row_id.blank?
    if @observation_matrix_row_id.blank?
      m = ObservationMatrix.where(project_id: project_id).find(@observation_matrix_id)
    else
      m = ObservationMatrixRow.find(@observation_matrix_row_id)&.observation_matrix
      @observation_matrix_id = m.id.to_s
    end
    m
  end

  def descriptor_available_languages
    descriptor_ids = @descriptors_with_filter.pluck(:id)
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
    descriptor_ids = descriptors.pluck(:id)
    tags = Keyword.joins(:tags)
                  .where(tags: {tag_object_type: 'Descriptor'})
                  .where('tags.tag_object_id IN (?)', descriptor_ids ).order('name').distinct.to_a
  end

  def descriptors
    t = ['Descriptor::Continuous', 'Descriptor::PresenceAbsence', 'Descriptor::Sample', 'Descriptor::Qualitative']
    if @observation_matrix_id.blank?
      Descriptor.not_weight_zero.where('type IN (?)', t).order(:position)
    else
      Descriptor.select('descriptors.*, observation_matrix_columns.position AS column_position').
        joins(:observation_matrix_columns).
        not_weight_zero.
        where('type IN (?)', t).
        where('observation_matrix_columns.observation_matrix_id = ?', @observation_matrix_id).
        order('observation_matrix_columns.position')
    end
  end

  def descriptors_with_keywords
    if @keyword_ids
      descriptors.joins(:tags).where('tags.keyword_id IN (?)', @keyword_ids.to_s.split('|').map(&:to_i) )
    else
      descriptors
    end
  end

  def otu_id_array
    if !@observation_matrix_row_id.blank?
      @otu_id = ObservationMatrixRow.find(@observation_matrix_row_id.to_i)&.otu_id
    end
    if @otu_id.blank?
      nil
    elsif @include_descendants == 'true'
      Otu.self_and_descendants_of(@otu_id.to_i).pluck(:id)
    else
      [@otu_id]
    end
  end

  def collection_object_id_array
    if @include_descendants = 'true' && !@otu_id_filter_array.blank?
      CollectionObject.joins(:taxon_determinations).where(taxon_determinations: {position: 1, otu_id: @otu_id_filter_array}).pluck(:id)
    elsif !@observation_matrix_row_id.blank?
      [ObservationMatrixRow.find(@observation_matrix_row_id.to_i)&.collection_object_id.to_i]
    else
      [0]
    end
  end

  def get_descriptor_hash
    descriptor_ids = @descriptors_with_filter.collect{|i| i.id}
    t = ['Observation::Continuous', 'Observation::PresenceAbsence', 'Observation::Sample']
    otu_ids = @otu_id_filter_array.to_a + [0]
    collection_object_ids = @collection_object_id_filter_array.to_a + [0]
    descriptor_hash = {}
    @descriptors_with_filter.each do |d|
      descriptor_hash[d.id] = {}
      descriptor_hash[d.id][:descriptor] = d
      descriptor_hash[d.id][:similar_otu_ids] = []
      descriptor_hash[d.id][:similar_collection_object_ids] = []
      descriptor_hash[d.id][:char_states] = [] if d.type == 'Descriptor::Qualitative'
      descriptor_hash[d.id][:char_states_ids] = [] if d.type == 'Descriptor::Qualitative'
      descriptor_hash[d.id][:min] = 999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # min value used as continuous or sample
      descriptor_hash[d.id][:max] = -999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # max value used as continuous or sample
      descriptor_hash[d.id][:presence] = nil if d.type == 'Descriptor::PresenceAbsence'
    end

    char_states = CharacterState.joins(:observations).
      where('character_states.descriptor_id IN (?) AND (otu_id IN (?) OR collection_object_id IN (?) )', descriptor_ids, otu_ids, collection_object_ids).
      uniq
    char_states.each do |cs|
      descriptor_hash[cs.descriptor_id][:char_states].append(cs)
      descriptor_hash[cs.descriptor_id][:char_states_ids].append(cs.id)
    end

    observations = Observation.where('observations.type IN (?) AND descriptor_id IN (?) AND (otu_id IN (?) OR collection_object_id IN (?) )', t, descriptor_ids, otu_ids, collection_object_ids).uniq
    observations.each do |o|
      if !o.continuous_value.nil?
        descriptor_hash[o.descriptor_id][:min] = o.continuous_value if descriptor_hash[o.descriptor_id][:min] > o.continuous_value
        descriptor_hash[o.descriptor_id][:max] = o.continuous_value if descriptor_hash[o.descriptor_id][:max] < o.continuous_value
      elsif !o.sample_min.nil?
        descriptor_hash[o.descriptor_id][:min] = o.sample_min if descriptor_hash[o.descriptor_id][:min] > o.sample_min
        if o.sample_max
          descriptor_hash[o.descriptor_id][:max] = o.sample_max if descriptor_hash[o.descriptor_id][:max] < o.sample_max
        else
          descriptor_hash[o.descriptor_id][:max] = o.sample_min if descriptor_hash[o.descriptor_id][:max] < o.sample_min
        end
      elsif !o.presence.nil?
        if o.presence == true && descriptor_hash[o.descriptor_id][:presence].nil?
          descriptor_hash[o.descriptor_id][:presence] = 'present'
        elsif o.presence == false && descriptor_hash[o.descriptor_id][:presence].nil?
          descriptor_hash[o.descriptor_id][:presence] = 'absent'
        elsif o.presence == true && descriptor_hash[o.descriptor_id][:presence] == 'absent'
          descriptor_hash[o.descriptor_id][:presence] = 'present or absent'
        elsif o.presence == false && descriptor_hash[o.descriptor_id][:presence] == 'present'
          descriptor_hash[o.descriptor_id][:presence] = 'present or absent'
        end
      end
    end

    otu_ids = @otu_id_filter_array + [0]
    collection_object_ids = @collection_object_id_filter_array + [0]

    unless @observation_matrix_id.nil?
      otu_ids_count = {}
      collection_object_ids_count = {}
      t = ['Descriptor::Continuous', 'Descriptor::PresenceAbsence', 'Descriptor::Sample']

      char_states = ObservationMatrix.
        select('descriptors.id AS d_id, character_states.id AS cs_id, observations.id AS o_id, observations.otu_id AS o_otu_id, observations.collection_object_id AS o_collection_object_id, observation_matrix_rows.otu_id AS r_otu_id, observation_matrix_rows.collection_object_id AS r_collection_object_id, observations.character_state_id AS o_cs_id').
        left_outer_joins(:descriptors).
        left_outer_joins(:observation_matrix_rows).
        joins('LEFT OUTER JOIN observations ON observations.descriptor_id = descriptors.id AND (observations.otu_id = observation_matrix_rows.otu_id OR observations.collection_object_id = observation_matrix_rows.collection_object_id )').
        joins('LEFT OUTER JOIN character_states ON character_states.id = observations.character_state_id').
        where("descriptors.type = 'Descriptor::Qualitative'").
        where('descriptors.id IN (?)', descriptor_ids).
        where('(observation_matrix_rows.otu_id NOT IN (?) OR observation_matrix_rows.otu_id IS NULL)', otu_ids).
        where('(observation_matrix_rows.collection_object_id NOT IN (?) OR observation_matrix_rows.collection_object_id IS NULL)', collection_object_ids).
        where('observation_matrices.id = ?', @observation_matrix_id)
      char_states.each do |cs|
        if !descriptor_hash[cs.d_id][:similar_otu_ids].include?(cs.r_otu_id) &&
           !descriptor_hash[cs.d_id][:similar_collection_object_ids].include?(cs.r_collection_object_id)
          if !cs.r_otu_id.nil? && (descriptor_hash[cs.d_id][:char_states_ids].include?(cs.cs_id) || cs.o_id.nil?)
            descriptor_hash[cs.d_id][:similar_otu_ids].append(cs.r_otu_id)
            otu_ids_count[cs.r_otu_id] = otu_ids_count[cs.r_otu_id].to_i + 1
          elsif !cs.r_collection_object_id.nil? && (descriptor_hash[cs.d_id][:char_states_ids].include?(cs.cs_id) || cs.o_id.nil?)
            descriptor_hash[cs.d_id][:similar_collection_object_ids].append(cs.r_collection_object_id)
            collection_object_ids_count[cs.r_collection_object_id] = collection_object_ids_count[cs.r_collection_object_id].to_i + 1
          end
        end
      end

      observations = ObservationMatrix.
        select('descriptors.id AS d_id, observations.id AS o_id, observations.otu_id AS o_otu_id, observations.collection_object_id AS o_collection_object_id, observations.type, observations.continuous_value, observations.sample_min, observations.sample_max, observations.presence AS o_presence, observation_matrix_rows.otu_id AS r_otu_id, observation_matrix_rows.collection_object_id AS r_collection_object_id, observations.character_state_id AS o_cs_id').
        left_outer_joins(:descriptors).
        left_outer_joins(:observation_matrix_rows).
        joins('LEFT OUTER JOIN observations ON observations.descriptor_id = descriptors.id AND (observations.otu_id = observation_matrix_rows.otu_id OR observations.collection_object_id = observation_matrix_rows.collection_object_id )').
        where('descriptors.type IN (?)', t).
        where('descriptors.id IN (?)', descriptor_ids).
        where('(observation_matrix_rows.otu_id NOT IN (?) OR observation_matrix_rows.otu_id IS NULL)', otu_ids).
        where('(observation_matrix_rows.collection_object_id NOT IN (?) OR observation_matrix_rows.collection_object_id IS NULL)', collection_object_ids).
        where('observation_matrices.id = ?', @observation_matrix_id)
      observations.each do |o|
        if !descriptor_hash[o.d_id][:similar_otu_ids].include?(o.r_otu_id) &&
           !descriptor_hash[o.d_id][:similar_collection_object_ids].include?(o.r_collection_object_id)
          yes = false
          if o.continuous_value.nil? && o.sample_min.nil? && o.o_presence.nil?
            yes = true
          elsif !o.continuous_value.nil? && o.continuous_value >= descriptor_hash[o.d_id][:min] && o.continuous_value <= descriptor_hash[o.d_id][:max]
            yes = true
          elsif !o.sample_max.nil? && o.sample_max >= descriptor_hash[o.d_id][:min] && o.sample_max <= descriptor_hash[o.d_id][:max]
            yes = true
          elsif !o.sample_min.nil? && o.sample_min >= descriptor_hash[o.d_id][:min] && o.sample_min <= descriptor_hash[o.d_id][:max]
            yes = true
          elsif !o.o_presence.nil? && o.o_presence == true && descriptor_hash[o.d_id][:presence].include?('present')
            yes = true
          elsif !o.o_presence.nil? && o.o_presence == false && descriptor_hash[o.d_id][:presence].include?('absent')
            yes = true
          end
          if !o.r_otu_id.nil? && yes
            descriptor_hash[o.d_id][:similar_otu_ids].append(o.r_otu_id)
            otu_ids_count[o.r_otu_id] = otu_ids_count[o.r_otu_id].to_i + 1
          elsif !o.r_collection_object_id.nil? && yes
            descriptor_hash[o.d_id][:similar_collection_object_ids].append(o.r_collection_object_id)
            collection_object_ids_count[o.r_collection_object_id] = collection_object_ids_count[o.r_collection_object_id].to_i + 1
          end
        end
      end
      @similar_objects = (otu_ids_count.to_a.map{|i| {otu_id: i[0], similarities: i[1]}} + collection_object_ids_count.to_a.map{|i| {collection_object_id: i[0], similarities: i[1]}}).sort_by{|j| -j[:similarities]}
    end

    descriptor_hash
  end

  def get_description
    return nil if @descriptor_hash.empty?
    or_separator = ' or '
    language = @language_id.blank? ? nil : @language_id.to_i
    str = ''
    descriptor_name = ''
    state_name = ''
    @descriptor_hash.each do |d_key, d_value|
      next if (d_value[:descriptor].type == 'Descriptor::Qualitative' && d_value[:char_states].empty?) ||
        ((d_value[:descriptor].type == 'Descriptor::Continuous' || d_value[:descriptor].type == 'Descriptor::Sample') && d_value[:min] == 999999) ||
        (d_value[:descriptor].type == 'Descriptor::PresenceAbsence' && d_value[:presence].nil?)
      descriptor_name_new = d_value[:descriptor].target_name(:description, language)
      if descriptor_name != descriptor_name_new
        descriptor_name = descriptor_name_new
        str += '. ' unless str.blank?
        str += descriptor_name + ' '
      else
        str += ', '
      end
      case d_value[:descriptor].type
      when 'Descriptor::Qualitative'
        st_str = []
        d_value[:char_states].each do |cs|
          st_str.append(cs.target_name(:description, language))
        end
        str += st_str.uniq.join(or_separator)
      when 'Descriptor::Continuous'
        if d_value[:min] == d_value[:max]
          str += ["%g" % d_value[:min], d_value[:descriptor].default_unit].compact.join(' ')
        else
          str += ["%g" % d_value[:min] + '–' + "%g" % d_value[:max], d_value[:descriptor].default_unit].compact.join(' ')
        end
      when 'Descriptor::Sample'
        if d_value[:min] == d_value[:max]
          str += ["%g" % d_value[:min], d_value[:descriptor].default_unit].compact.join(' ')
        else
          str += ["%g" % d_value[:min] + '–' + "%g" % d_value[:max], d_value[:descriptor].default_unit].compact.join(' ')
        end
      when 'Descriptor::PresenceAbsence'
        str += d_value[:presence].to_s
      end
    end
    str += '.' unless str.blank?
    str
  end

  def get_diagnosis
    return nil if @descriptor_hash.empty?
    descriptor_array = @descriptor_hash.values.sort_by{|i| i[:similar_otu_ids].count + i[:similar_collection_object_ids].count}

    i = 2
    i_max = descriptor_array.count

    #    while i < imax && imax > 2
      #if descriptor_array[i][:similar_otu_ids] & descriptor_array[i-1][:similar_otu_ids]
      i +=1
    #    end

    or_separator = ' or '
    language = @language_id.blank? ? nil : @language_id.to_i
    str = ''
    descriptor_name = ''
    state_name = ''
    remaining_otus = descriptor_array.first[:similar_otu_ids].to_a
    remaining_co = descriptor_array.first[:similar_collection_object_ids].to_a
    descriptor_array.each do |d_value|
      remaining_otus = remaining_otus & d_value[:similar_otu_ids].to_a
      remaining_co = remaining_co & d_value[:similar_collection_object_ids].to_a
      next if (d_value[:descriptor].type == 'Descriptor::Qualitative' && d_value[:char_states].empty?) ||
        ((d_value[:descriptor].type == 'Descriptor::Continuous' || d_value[:descriptor].type == 'Descriptor::Sample') && d_value[:min] == 999999) ||
        (d_value[:descriptor].type == 'Descriptor::PresenceAbsence' && d_value[:presence].nil?)
      descriptor_name_new = d_value[:descriptor].target_name(:description, language)
      if descriptor_name != descriptor_name_new
        descriptor_name = descriptor_name_new
        str += '. ' unless str.blank?
        str += descriptor_name + ' '
      else
        str += ', '
      end
      case d_value[:descriptor].type
      when 'Descriptor::Qualitative'
        st_str = []
        d_value[:char_states].each do |cs|
          st_str.append(cs.target_name(:description, language))
        end
        str += st_str.uniq.join(or_separator)
      when 'Descriptor::Continuous'
        if d_value[:min] == d_value[:max]
          str += ["%g" % d_value[:min], d_value[:descriptor].default_unit].compact.join(' ')
        else
          str += ["%g" % d_value[:min] + '–' + "%g" % d_value[:max], d_value[:descriptor].default_unit].compact.join(' ')
        end
      when 'Descriptor::Sample'
        if d_value[:min] == d_value[:max]
          str += ["%g" % d_value[:min], d_value[:descriptor].default_unit].compact.join(' ')
        else
          str += ["%g" % d_value[:min] + '–' + "%g" % d_value[:max], d_value[:descriptor].default_unit].compact.join(' ')
        end
      when 'Descriptor::PresenceAbsence'
        str += d_value[:presence].to_s
      end
      break if remaining_otus.empty? && remaining_co.empty?
    end
    if remaining_otus.empty? && remaining_co.empty?
      str += '.' unless str.blank?
    else
      str = 'Cannot be separated from other rows in the matrix!'
    end
    str
  end


end
