# Contains methods used to build an interactive key
class InteractiveKey

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

  # @!sorting
  #   @return [String or null]
  # Optional attribute to sort the list of descriptors. Options: 'ordered', 'weighted', 'optimized'. Optimized is a default if nothing is provided
  attr_accessor :sorting

  # @!eliminate_unknown
  #   @return [Boolean or null]
  # Optional attribute to eliminate taxa with no scores on a used descriptor: 'false' - default or 'true'
  # If true, the rows without scores will be eliminated
  attr_accessor :eliminate_unknown

  # @!error_tolerance
  #   @return [Integer or null]
  # Optional attribute. Number of allowed errors during identification
  attr_accessor :error_tolerance

  # @!identified_to_rank
  #   @return [String or null]
  # Optional attribute to limit identification to OTU or a particular nomenclatural rank. Valid values are 'otu', 'species', 'genus', etc.
  attr_accessor :identified_to_rank

  # @!selected_descriptors
  #   @return [String or null]
  # Optional attribute: descriptors and states selected during identification "123:1|3||125:3|5||135:2||140:3-5"
  # Each used descriptor is separated by '||'.
  # States or values are separated from descriptors with ':'.
  # Multiple selected character_states for one descriptor are separated by '|'.
  # Sample states can use numerical ranges
  attr_accessor :selected_descriptors

  ##### RETURNED DATA ######

  # @!observation_matrix
  #   @return [Object]
  # Returns observation_matrix as an object
  attr_accessor :observation_matrix

  # @!observation_matrix_citation
  #   @return [Object]
  # Returns observation_matrix_citation as an object
  attr_accessor :observation_matrix_citation

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
  # Each descriptor has an attribute :status, which could be 'used', 'useful', 'useless' for further identification
  attr_accessor :list_of_descriptors

  # @!remaining
  #   @return [Array]
  # Returns the list of objects not eliminated by previously used descriptors.
  # The list may include collection_objects OR otus OR valid taxon_names
  attr_accessor :remaining

  # @!eliminated
  #   @return [Array]
  # Returns the list of objects eliminated by previously used descriptors.
  # The list may include collection_objects OR otus OR valid taxon_names
  attr_accessor :eliminated

  # @!selected_descriptors_hash
  #   @return [Hash]
  # selected_descriptors String is converted into Hash
  attr_accessor :selected_descriptors_hash

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
    sorting: 'weighted',
    error_tolerance: 0,
    identified_to_rank: nil,
    eliminate_unknown: nil,
    selected_descriptors: nil)

    # raise if observation_matrix_id.blank? || project_id.blank?
    @observation_matrix_id = observation_matrix_id
    @project_id = project_id
    @observation_matrix = ObservationMatrix.where(project_id: project_id).find(observation_matrix_id)
    @observation_matrix_citation = @observation_matrix.source
    @descriptor_available_languages = descriptor_available_languages
    @language_id = language_id
    @language_to_use = language_to_use
    @keyword_ids = keyword_ids
    @descriptor_available_keywords = descriptor_available_keywords
    @descriptors_with_filter = descriptors_with_keywords
    @row_filter = row_filter
    @otu_filter = otu_filter
    @row_id_filter_array = row_filter_array
    @otu_id_filter_array = otu_filter_array
    @rows_with_filter = get_rows_with_filter
    @sorting = sorting
    @error_tolerance = error_tolerance.to_i
    @eliminate_unknown = eliminate_unknown == 'true' ? true : false
    @identified_to_rank = identified_to_rank
    @selected_descriptors = selected_descriptors
    @selected_descriptors_hash = selected_descriptors_hash_initiate
    @row_hash = row_hash_initiate
    @descriptors_hash = descriptors_hash_initiate
    ###main_logic
    @remaining = remaining_taxa
    @eliminated = eliminated_taxa
    @list_of_descriptors = useful_descriptors
    ###delete temporary data
    @row_hash = nil
    @descriptors_hash = nil
    @rows_with_filter = nil
    @descriptors_with_filter = nil
  end

  def observation_matrix
    ObservationMatrix.where(id: @observation_matrix_id, project_id: @project_id).first
  end

  def descriptors
    if @sorting == 'weighted'
      observation_matrix.descriptors.not_weight_zero.order('descriptors.weight DESC, descriptors.position')
    else
      observation_matrix.descriptors.not_weight_zero.order(:position)
    end
  end

  def descriptor_available_languages
    descriptor_ids = descriptors.pluck(:id)
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

  def descriptors_with_keywords
    if @keyword_ids
      descriptors.joins(:tags).where('tags.keyword_id IN (?)', @keyword_ids.to_s.split('|').map(&:to_i) )
    else
      descriptors
    end
  end

  # This doesn't return rows, it re-orders them in *database*
  def rows
    observation_matrix.reorder_rows(by = 'nomenclature')
  end

  def row_filter_array
    @row_filter.blank? ? nil : row_filter.to_s.split('|').map(&:to_i)
  end

  def otu_filter_array
    @otu_filter.blank? ? nil : otu_filter.to_s.split('|').map(&:to_i)
  end

  def get_rows_with_filter
    observation_matrix.observation_matrix_rows.order(:position)
  end

  ## row_hash: {otu_collection_object: {:object,           ### (collection_object or OTU)
  ##                     :object_at_rank,   ### (converted to OTU or TN)
  ##                     :row_id,
  ##                     :otu_id,
  ##                     :errors,           ### (calculated number of errors)
  ##                     :status }}         ### ('remaining', 'eliminated')
  def row_hash_initiate
    h = {}
    rows_with_filter.each do |r|
      otu_collection_object = r.otu_id.to_s + '|' + r.collection_object_id.to_s
      h[otu_collection_object] = {}
      h[otu_collection_object][:object] = r
      if @identified_to_rank == 'otu'
        h[otu_collection_object][:object_at_rank] = r.current_otu || r
      elsif @identified_to_rank
        h[otu_collection_object][:object_at_rank] = r&.current_taxon_name&.ancestor_at_rank(@identified_to_rank, inlude_self = true) || r
      else
        h[otu_collection_object][:object_at_rank] = r
      end
      h[otu_collection_object][:otu_id] = r.otu_id ? r.otu_id : r.current_otu.id
      h[otu_collection_object][:errors] = 0
      h[otu_collection_object][:error_descriptors] = []
      h[otu_collection_object][:status] = 'remaining' ### if number of errors > @error_tolerance, replaced to 'eliminated'
    end
    h
  end

  ## descriptors_hash: {descriptor.id: {:descriptor,           ### (descriptor)
  ##                                    :observations,         ### (array of observations for )
  ##                                    :state_ids,            ### {hash of state_ids used in the particular matrix}
  ##                                    }}
  def descriptors_hash_initiate
    h = {}
    descriptors_with_keywords.each do |d|
      h[d.id] = {}
      h[d.id][:descriptor] = d
      h[d.id][:weight_index] = 0
      h[d.id][:state_ids] = {}
      h[d.id][:count] = 0
      h[d.id][:min] = 999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # min value used as continuous or sample
      h[d.id][:max] = -999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # max value used as continuous or sample
      h[d.id][:observations] = {} # all observation for a particular
      h[d.id][:observation_hash] = {} ### state_ids, true/false for a particular descriptor/otu_id/catalog_id combination (for PresenceAbsence or Qualitative or Continuous)
      h[d.id][:status] = 'useless' ### 'used', 'useful', 'useless'
      h[d.id][:status] = 'used' if @selected_descriptors_hash[d.id]
    end
    t = "'Observation::Continuous', 'Observation::PresenceAbsence', 'Observation::Qualitative', 'Observation::Sample'"

    @observation_matrix.observations.where('"observations"."type" IN (' + t + ')').each do |o|
      if h[o.descriptor_id]
        otu_collection_object = o.otu_id.to_s + '|' + o.collection_object_id.to_s
        h[o.descriptor_id][:observations][otu_collection_object] = [] if h[o.descriptor_id][:observations][otu_collection_object].nil? #??????
        h[o.descriptor_id][:observations][otu_collection_object] += [o]                                                                #??????
        h[o.descriptor_id][:observation_hash][otu_collection_object] = [] if h[o.descriptor_id][:observation_hash][otu_collection_object].nil?
        h[o.descriptor_id][:observation_hash][otu_collection_object] += [o.character_state_id.to_s] if o.character_state_id
        h[o.descriptor_id][:observation_hash][otu_collection_object] += ["%g" % o.continuous_value] if o.continuous_value
        h[o.descriptor_id][:observation_hash][otu_collection_object] += [o.presence.to_s] unless o.presence.nil?
      end
    end
    h
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

  def remaining_taxa
    #    @error_tolerance  - integer
    #    @eliminate_unknown  'true' or 'false'
    #    @descriptors_hash

    h = {}
    language = @language_id.blank? ? nil : @language_id.to_i

    @row_hash.each do |r_key, r_value|
      @selected_descriptors_hash.each do |d_key, d_value|
        otu_collection_object = r_value[:object].otu_id.to_s + '|' + r_value[:object].collection_object_id.to_s
        next if @descriptors_hash[d_key].blank?
        d_name = @descriptors_hash[d_key][:descriptor].target_name(:key, language) + ': '
        if @eliminate_unknown && @descriptors_hash[d_key][:observation_hash][otu_collection_object].nil?
          r_value[:errors] += 1
          r_value[:error_descriptors] += [d_name + 'unknown']
        elsif @descriptors_hash[d_key][:observation_hash][otu_collection_object].nil?
          #character not scored but no error
        else
          case @descriptors_hash[d_key][:descriptor].type
          when 'Descriptor::Continuous'
            if (@descriptors_hash[d_key][:observation_hash][otu_collection_object] & d_value).empty?
              r_value[:errors] += 1
              str = d_name + @descriptors_hash[d_key][:observations][otu_collection_object].collect{|o| "%g" % o.continuous_value}.join(' OR ')
              r_value[:error_descriptors] += [str]
            end
          when 'Descriptor::PresenceAbsence'
            if (@descriptors_hash[d_key][:observation_hash][otu_collection_object] & d_value).empty?
              r_value[:errors] += 1
              str = d_name + @descriptors_hash[d_key][:observations][otu_collection_object].collect{|o| o.presence}.join(' OR ')
              r_value[:error_descriptors] += [str]
            end
          when 'Descriptor::Qualitative'
            if (@descriptors_hash[d_key][:observation_hash][otu_collection_object] & d_value).empty?
              r_value[:errors] += 1
              str = d_name + @descriptors_hash[d_key][:observations][otu_collection_object].collect{|o| o.character_state.target_name(:key, language)}.join(' OR ')
              r_value[:error_descriptors] += [str]
            end
          when 'Descriptor::Sample'
            p = false
            a = d_value.first.split('-')
            d_min = a[0].to_f
            d_max = a[1].nil? ? d_min : a[1].to_f
            @descriptors_hash[d_key][:observations][otu_collection_object].each do |o|
              s_min = o.sample_min.to_f
              s_max = o.sample_max.nil? ? s_min : o.sample_max.to_f
              p = true if (d_min >= s_min && d_min <= s_max) || (d_max >= s_min && d_max <= s_max) || (d_min <= s_min && d_max >= s_max)
            end
            if p == false
              r_value[:errors] += 1
              str = d_name + @descriptors_hash[d_key][:observations][otu_collection_object].collect{|o| o.sample_min.to_s + '–' + o.sample_max.to_s}.join(' OR ')
              r_value[:error_descriptors] += [str]
            end
          end
        end
      end
      obj = r_value[:object_at_rank].class.to_s + '|' + r_value[:object_at_rank].id.to_s

      if (@row_id_filter_array && !@row_id_filter_array.include?(r_value[:object].id)) ||
            (@otu_id_filter_array && !@otu_id_filter_array.include?(r_value[:otu_id]))
        r_value[:status] = 'eliminated'
        r_value[:errors] = 'F'
        r_value[:error_descriptors] = ['Filtered out']
      end

      if r_value[:errors] == 'F' || r_value[:errors] > @error_tolerance
        r_value[:status] = 'eliminated'
      elsif h[obj].nil?
          h[obj] =
              {object: r_value[:object_at_rank],
               row_id: r_value[:object].id,
               errors: r_value[:errors],
               error_descriptors: r_value[:error_descriptors]
              }
      end
    end
    return h.values
  end

  def eliminated_taxa
    h = {}
    @row_hash.each do |r_key, r_value|
      obj = r_value[:object_at_rank].class.to_s + '|' + r_value[:object_at_rank].id.to_s
      if r_value[:status] == 'eliminated' && !@remaining.include?(r_value[:object_at_rank].class.to_s + '|' + r_value[:object_at_rank].id.to_s)
        h[obj] =
            {object: r_value[:object_at_rank],
             row_id: r_value[:object].id,
             errors: r_value[:errors],
             error_descriptors: r_value[:error_descriptors]
            } if h[obj].nil?
      end
    end
    return h.values
  end

  def useful_descriptors
    list_of_remaining_taxa = {}
    language = @language_id.blank? ? nil : @language_id.to_i
    @row_hash.each do |r_key, r_value|
      if r_value[:status] != 'eliminated'
        list_of_remaining_taxa[r_value[:object_at_rank] ] = true
      end
    end
    number_of_taxa = list_of_remaining_taxa.count
    array_of_descriptors = []

    @descriptors_hash.each do |d_key, d_value|
      taxa_with_unknown_character_states = list_of_remaining_taxa if @eliminate_unknown == false
      d_value[:observations].each do |otu_key, otu_value|
        otu_collection_object = otu_key
        if true #@row_hash[otu_collection_object]
          otu_value.each do |o|
            if o.character_state_id
              d_value[:state_ids][o.character_state_id.to_s] = {} if d_value[:state_ids][o.character_state_id.to_s].nil?
              d_value[:state_ids][o.character_state_id.to_s][:rows] = {} if d_value[:state_ids][o.character_state_id.to_s][:rows].nil? ## rows which this state identifies
              d_value[:state_ids][o.character_state_id.to_s][:rows][ @row_hash[otu_collection_object][:object_at_rank] ] = true if @row_hash[otu_collection_object][:status] != 'eliminated'
              if @selected_descriptors_hash[d_key] && @selected_descriptors_hash[d_key].include?(o.character_state_id.to_s)
                d_value[:state_ids][o.character_state_id.to_s][:status] = 'used' ## 'used', 'useful', 'useless'
              else
                d_value[:state_ids][o.character_state_id.to_s][:status] = 'useful' ## 'used', 'useful', 'useless'
              end
            end
            unless o.presence.nil?
              d_value[:state_ids][o.presence.to_s] = {} if d_value[:state_ids][o.presence.to_s].nil?
              d_value[:state_ids][o.presence.to_s][:rows] = {} if d_value[:state_ids][o.presence.to_s][:rows].nil? ## rows which this state identifies
              d_value[:state_ids][o.presence.to_s][:rows][ @row_hash[otu_collection_object][:object_at_rank] ] = true if @row_hash[otu_collection_object][:status] != 'eliminated'
              if @selected_descriptors_hash[d_key] && @selected_descriptors_hash[d_key].include?(o.presence.to_s)
                d_value[:state_ids][o.presence.to_s][:status] = 'used' ## 'used', 'useful', 'useless'
              else
                d_value[:state_ids][o.presence.to_s][:status] = 'useful' ## 'used', 'useful', 'useless'
              end
            end
            unless o.continuous_value.nil?
              d_value[:state_ids][o.id] = true
              if @row_hash[otu_collection_object][:status] != 'eliminated'
                d_value[:count] +=1
                d_value[:min] = o.continuous_value if d_value[:min] > o.continuous_value
                d_value[:max] = o.continuous_value if d_value[:max] < o.continuous_value
              end
            end
            unless o.sample_min.nil?
              d_value[:state_ids][o.id] = {o_min: o.sample_min.to_f, o_max: o.sample_max.to_f}
              if @row_hash[otu_collection_object][:status] != 'eliminated'
                d_value[:count] +=1
                d_value[:min] = o.sample_min if d_value[:min] > o.sample_min
                if o.sample_max
                  d_value[:max] = o.sample_max if d_value[:max] < o.sample_max
                else
                  d_value[:max] = o.sample_min if d_value[:max] < o.sample_min
                end
              end
            end
            taxa_with_unknown_character_states[ @row_hash[otu_collection_object][:object_at_rank] ] = false if @eliminate_unknown == false
          end
        end
      end
      number_of_taxa_with_unknown_character_states = 0
      number_of_taxa_with_unknown_character_states = taxa_with_unknown_character_states.select{|key, value| value == true}.count if @eliminate_unknown == false

      descriptor = {}
      descriptor[:id] = d_key
      descriptor[:type] = d_value[:descriptor].type
      descriptor[:name] = d_value[:descriptor].target_name(:key, language)
      descriptor[:weight] = d_value[:descriptor].weight
      descriptor[:position] = d_value[:descriptor].position
      descriptor[:usefulness] = 0
      descriptor[:status] = d_value[:status] == 'used' ? 'used' : 'useless'
      descriptor[:description] = d_value[:descriptor].description
      descriptor[:depiction_ids] = d_value[:descriptor].depictions.order(:position).pluck(:id)

      s = 0
      case d_value[:descriptor].type
      when 'Descriptor::Qualitative'
        number_of_states = d_value[:state_ids].count
        descriptor[:states] = []
        d_value[:state_ids].each do |s_key, s_value|
          c = CharacterState.find(s_key.to_i)
          state = {}
          state[:id] = c.id
          state[:name] = c.target_name(:key, language)
          state[:position] = c.position
          state[:label] = c.label
          state[:number_of_objects] = s_value[:rows].count + number_of_taxa_with_unknown_character_states
          state[:status] = s_value[:status] == 'used' ? 'used' : 'useful'
          n = s_value[:rows].count
          if descriptor[:status] == 'used'
            #do nothing
          elsif n == number_of_taxa || n == 0
            s_value[:status] = 'useless'
            state[:status] = 'useless'
          else
            d_value[:status] = 'useful'
            descriptor[:status] = 'useful'
          end
          state[:depiction_ids] = c.depictions.order(:position).pluck(:id)

          #          weight = rem_taxa/number_of_states + squer (sum (rem_taxa/number_of_states - taxa_in_each_state)^2)
          s += (number_of_taxa / number_of_states - s_value[:rows].count) ** 2
          descriptor[:states] += [state]
        end
        descriptor[:usefulness] = number_of_taxa / number_of_states + Math.sqrt(s) if number_of_states > 0
        descriptor[:states].sort_by!{|i| i[:position]}
      when 'Descriptor::Continuous'
        descriptor[:default_unit] = d_value[:descriptor].default_unit
        descriptor[:min] = d_value[:min]
        descriptor[:max] = d_value[:max]
        number_of_measurements = d_value[:count]
        s = (d_value[:min] - (d_value[:min] / 10)) / (d_value[:max] - d_value[:min])
        descriptor[:usefulness] = number_of_taxa * s * (2 - (number_of_measurements / number_of_taxa)) if number_of_taxa > 0
        if descriptor[:status] != 'used' && descriptor[:min] != descriptor[:max]
          d_value[:status] = 'useful'
          descriptor[:status] = 'useful'
        end
      when 'Descriptor::Sample'
        descriptor[:default_unit] = d_value[:descriptor].default_unit
        descriptor[:min] = d_value[:min]
        descriptor[:max] = d_value[:max]
        number_of_measurements = d_value[:count]
        #                               i = max - min ; if 0 then (numMax - numMin / 10)
        #                               sum of all i
        #                               if numMax = numMin then numMax = numMax + 0.00001
        #                               weight = rem_taxa * (sum of i / number of measuments for taxon / (numMax - numMin) ) * (2 - number of measuments for taxon / rem_taxa)
        if d_value[:max] != d_value[:min]
          d_value[:state_ids].each do |s_key, s_value|
            if s_value[:o_min] == s_value[:o_max] || s_value[:o_max].blank?
              s += (s_value[:o_max] - s_value[:o_min]) / number_of_measurements / (d_value[:max] - d_value[:min])
            else
              s += (s_value[:o_min] - (s_value[:o_min] / 10)) / number_of_measurements / (d_value[:max] - d_value[:min])
            end
            if descriptor[:status] != 'used' && (s_value[:o_min] != d_value[:min] || (!s_value[:o_max].blank? && s_value[:o_max] != d_value[:max]))
              d_value[:status] = 'useful'
              descriptor[:status] = 'useful'
            end
          end
        end
        descriptor[:usefulness] = number_of_taxa * s * (2 - (number_of_measurements / number_of_taxa)) if number_of_taxa > 0

      when 'Descriptor::PresenceAbsence'
        number_of_states = 2
        descriptor[:states] = []
        d_value[:state_ids].each do |s_key, s_value|
          state = {}
          state[:name] = s_key
          state[:number_of_objects] = s_value[:rows].count + number_of_taxa_with_unknown_character_states
          state[:status] = s_value[:status] == 'used' ? 'used' : 'useful'
          n = s_value[:rows].count
          if descriptor[:status] == 'used'
            #do nothing
          elsif n == number_of_taxa || n == 0
            s_value[:status] = 'useless'
            state[:status] = 'useless'
          else
            d_value[:status] = 'useful'
          end
          s = (number_of_taxa / number_of_states - s_value[:rows].count) ** 2
          descriptor[:states] += [state]
        end
        descriptor[:usefulness] = number_of_taxa / number_of_states + Math.sqrt(s) if number_of_states > 0
        descriptor[:states].sort_by!{|i| -i[:name]}
      end
      descriptor[:min] = "%g" % descriptor[:min] if descriptor[:min]
      descriptor[:max] = "%g" % descriptor[:max] if descriptor[:max]
      array_of_descriptors += [descriptor]
    end

    case @sorting
    when 'ordered'
      array_of_descriptors.sort_by!{|i| i[:position]}
    when 'weighted'
      array_of_descriptors.sort_by!{|i| [-i[:weight].to_i, i[:usefulness]] }
    when 'optimized'
      array_of_descriptors.sort_by!{|i| i[:usefulness]}
    end

  end

end


