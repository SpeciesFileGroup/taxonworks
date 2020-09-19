# Contains methods used to build an interactive key
class InteractiveKey

  # required attribude to build the key
  attr_accessor :observation_matrix_id

  #required attribute to build the key
  attr_accessor :project_id

  #returns ObservationMatrix object
  attr_accessor :observation_matrix

  #optional attribute to display the characters in a particular language
  attr_accessor :language_id

  #optional attribute to provide a list of tagIDs to limit the set of characters "1|5|15"
  attr_accessor :keyword_ids

  #optional attribute to provide a list of rowIDs to limit the set "1|5|10"
  attr_accessor :row_filter

  #optional attribute to sort the list of descriptors. Options: 'ordered', 'weighted', 'optimized', a default
  attr_accessor :sorting

  #optional attribute to eliminate taxa with not scored descriptors: 'false' - default or 'true'
  attr_accessor :eliminate_unknown

  #optional attribute number of allowed erros during identification
  attr_accessor :error_tolerance

  #limit identification to a particular nomenclatural rank 'genus', 'species', 'otu'
  attr_accessor :identified_to_rank

  #optional attribute: descriptors and states selected during identification "123:1|3||125:3|5||135:2"
  attr_accessor :selected_descriptors

  #returns the list of Languages used as translations for descriptors
  attr_accessor :descriptor_available_languages

  #returns the list of all descriptors for this matrix
  attr_accessor :descriptors

  #returns the list of all Tags used with the descriptors
  attr_accessor :descriptor_available_keywords

  #the validated Language object to display descriptors in a particular language
  attr_accessor :language_to_use

  #list of descriptors reduced by keyword_ids
  attr_accessor :descriptors_with_filter

  #list of rows to be included into the matrix
  attr_accessor :rows_with_filter

  #return the list of descriptors with selections
  #  attr_accessor :used_descriptors

  #return the list of useful descriptors
  #  attr_accessor :useful_descriptors

  #return the list of descriptors not useful for identification
  #  attr_accessor :not_useful_descriptors

  #return the list of descriptors and thair states
  attr_accessor :list_of_descriptors

  #list of remaining rows
  attr_accessor :remaining

  #list of eliminated rows
  attr_accessor :eliminated

  #hash of used descriptors and their states
  attr_accessor :selected_descriptors_hash

  #temporary hash of rows; used for calculation of remaining and eliminated rows
  attr_accessor :row_hash

  #temporary hash of descriptors; used for calculation of useful and not useful characters and their states
  attr_accessor :descriptors_hash

  def initialize(
    observation_matrix_id: nil,
    project_id: nil,
    language_id: nil,
    keyword_ids: nil,
    row_filter: nil,
    sorting: 'optimized',
    error_tolerance: 0,
    identified_to_rank: nil,
    eliminate_unknown: nil,
    selected_descriptors: nil)

    # raise if observation_matrix_id.blank? || project_id.blank?
    @observation_matrix_id = observation_matrix_id
    @project_id = project_id

    # This is nothing?   
    # @observation_matrix = observation_matrix

    # Do you mean
    @observation_matrix = ObservationMatrix.where(project_id: project_id).find(observation_matrix_id)

    @descriptor_available_languages = descriptor_available_languages
    @language_id = language_id
    @language_to_use = language_to_use
    @keyword_ids = keyword_ids
    @descriptor_available_keywords = descriptor_available_keywords
    @descriptors_with_filter = descriptors_with_keywords
    @row_filter = row_filter
    @rows_with_filter = get_rows_with_filter
    @sorting = sorting
    @error_tolerance = error_tolerance.to_i
    @eliminate_unknown = eliminate_unknown == 'true' ? true : false
    @identified_to_rank = identified_to_rank
    @selected_descriptors = selected_descriptors
    @selected_descriptors_hash = selected_descriptors_hash_initiate
    @row_hash = row_hash_initiate
    @descriptors_hash = descriptors_hash_initiate

    #main_logic
    @remaining = remaining_taxa
    @eliminated = eliminated_taxa

    @list_of_descriptors = useful_descriptors
    #    @useful_descriptors = useful_descriptors
    #    @used_descriptors ###
    #    @not_useful_descriptors ####

    @row_hash = nil
    @descriptors_hash = nil

  end

  def self.interactive_key_hash
    {
      observation_matrix_id: @observation_matrix_id,
      project_id: @project_id,
      observation_matrix: @observation_matrix,
      descriptor_available_languages: @descriptor_available_languages,
      language_id: @language_id,
      language_to_use: @language_to_use,
      keyword_ids: @keyword_ids,
      descriptor_available_keywords: @descriptor_available_keywords,
      descriptors_with_filter: @descriptors_with_filter,
      row_filter: @row_filter,
      rows_with_filter: @rows_with_filter,
      sorting: @sorting,
      error_tolerance: @error_tolerance,
      eliminate_unknown: @eliminate_unknown,
      identified_to_rank: @identified_to_rank,
      selected_descriptors: @selected_descriptors,
      selected_descriptors_hash: @selected_descriptors_hash,
      remaining: @remaining,
      eliminated: @eliminated,
      list_of_descriptors: @list_of_descriptors
    }
  end

  def observation_matrix
    ObservationMatrix.where(id: @observation_matrix_id, project_id: @project_id).first
  end

  def descriptors
    if @sorting == 'weighted'
      observation_matrix.descriptors.where('NOT descriptors.weight = 0 OR descriptors.weight IS NULL').order('descriptors.weight DESC, descriptors.position')
    else
      observation_matrix.descriptors.where('NOT descriptors.weight = 0 OR descriptors.weight IS NULL').order(:position)
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
    return nil if l.nil? || !descriptor_available_languages.to_a.include?(l)
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
      descriptors.joins(:tags).where('tags.keyword_id IN (?)', @keyword_ids.to_s.split('|') )
    else
      descriptors
    end
  end

  # This doesn't return rows, it re-orders them in *database*
  def rows
    observation_matrix.reorder_rows(by = 'nomenclature')
  end

  def get_rows_with_filter
    if @row_filter.blank?
      observation_matrix.observation_matrix_rows.order(:position)
    else
      observation_matrix.observation_matrix_rows.where('observation_matrix_rows.id IN (?)', @row_filter.to_s.split('|')).order(:position)
    end
  end

  ## row_hash: {otu_collection_object: {:object,           ### (collection_object or OTU)
  ##                     :object_at_rank,   ### (converted to OTU or TN)
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
        h[otu_collection_object][:object_at_rank] = r.current_taxon_name.ancestor_at_rank(@identified_to_rank, inlude_self = true) || r
      else
        h[otu_collection_object][:object_at_rank] = r
      end
      h[otu_collection_object][:errors] = 0
      h[otu_collection_object][:error_descriptors] = {}
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
      h[d.id][:min] = 999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # min value used as continuous or sample
      h[d.id][:max] = -999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # max value used as continuous or sample
      h[d.id][:observations] = {} # all observation for a particular
      h[d.id][:observation_hash] = {} ### state_ids, true/false for a particular descriptor/otu_id/catalog_id combination (for PresenceAbsence or Qualitative or Continuous)
      h[d.id][:status] = 'useless' ### 'used', 'useful', 'useless'
    end
    t = "'Observation::Continuous', 'Observation::PresenceAbsence', 'Observation::Qualitative', 'Observation::Sample'"
    @observation_matrix.observations.where('"observations"."type" IN (' + t + ')').each do |o|
      if h[o.descriptor_id]
        otu_collection_object = o.otu_id.to_s + '|' + o.collection_object_id.to_s
        h[o.descriptor_id][:observations][otu_collection_object] = [] if h[o.descriptor_id][:observations][otu_collection_object].nil? #??????
        h[o.descriptor_id][:observations][otu_collection_object] += [o]                                                                #??????
        h[o.descriptor_id][:min] = o.continuous_value if o.continuous_value && h[o.descriptor_id][:min] && o.continuous_value < h[o.descriptor_id][:min]
        h[o.descriptor_id][:max] = o.continuous_value if o.continuous_value && h[o.descriptor_id][:max] && o.continuous_value > h[o.descriptor_id][:max]
        h[o.descriptor_id][:min] = o.sample_min if o.sample_min && h[o.descriptor_id][:min] && o.sample_min < h[o.descriptor_id][:min]
        h[o.descriptor_id][:max] = o.sample_max if o.sample_max && h[o.descriptor_id][:max] && o.sample_max > h[o.descriptor_id][:max]
        h[o.descriptor_id][:observation_hash][otu_collection_object] = [] if h[o.descriptor_id][:observation_hash][otu_collection_object].nil?
        h[o.descriptor_id][:observation_hash][otu_collection_object] += [o.character_state_id.to_s] if o.character_state_id
        h[o.descriptor_id][:observation_hash][otu_collection_object] += [o.continuous_value.to_s] if o.continuous_value
        h[o.descriptor_id][:observation_hash][otu_collection_object] += [o.presence.to_s] unless o.presence.nil?
      end
    end
    h
  end

  # returns {123: ['1', '3'], 125: ['3', '5'], 135: ['2'], 136: ['true'], 140: ['5-10']}
  def selected_descriptors_hash_initiate
    # "123:1|3||125:3|5||135:2"
    h = {}
    a = @selected_descriptors.to_s.split('||')
    a.each do |i|
      d = i.split(':')
      h[d[0]].to_i = d[1].split('|')
      @descriptors_hash[h[d[0]].to_i][:status] = 'used'
    end
    h
  end

  def remaining_taxa
    #    @error_tolerance  - integer
    #    @eliminate_unknown  'true' or 'false'
    #    @descriptors_hash

    h = {}
    @row_hash.each do |r_key, r_value|
      @selected_descriptors_hash.each do |d_key, d_value|
        otu_collection_object = r_value[:object].otu_id.to_s + '|' + r_value[:object].collection_object_id.to_s
        if @eliminate_unknown && @descriptors_hash[d_key][:observation_hash][otu_collection_object].nil?
          r_value[:errors] += 1
          r_value[:error_descriptors][@descriptors_hash[d_key][:descriptor]] = []
        elsif @descriptors_hash[d_key][:observation_hash][otu_collection_object].nil?
          #character not scored but no error
        else
          case @descriptors_hash[d_key][:descriptor].type
          when 'Descriptor::Continuous'
            r_value[:errors] += 1 if (@descriptors_hash[d_key][:observation_hash][otu_collection_object] & d_value).empty?
            r_value[:error_descriptors][@descriptors_hash[d_key][:descriptor]] = @descriptors_hash[d_key][:observations][otu_collection_object]
          when 'Descriptor::PresenceAbsence'
            r_value[:errors] += 1 if (@descriptors_hash[d_key][:observation_hash][otu_collection_object] & d_value).empty?
            r_value[:error_descriptors][@descriptors_hash[d_key][:descriptor]] = @descriptors_hash[d_key][:observations][otu_collection_object]
          when 'Descriptor::Qualitative'
            r_value[:errors] += 1 if (@descriptors_hash[d_key][:observation_hash][otu_collection_object] & d_value).empty?
            r_value[:error_descriptors][@descriptors_hash[d_key][:descriptor]] = @descriptors_hash[d_key][:observations][otu_collection_object]
          when 'Descriptor::Sample'
            p = false
            a = d_value.split('-')
            d_min = a[0]
            d_max = a[1].nil? ? a[0] : a[1]
            @descriptors_hash[d_key][:observations][otu_collection_object].each do |o|
              p = true if o.sample_min <= d_min.to_i || o.sample_max >= d_max.to_i
            end
            r_value[:errors] += 1 if p == false
            r_value[:error_descriptors][@descriptors_hash[d_key][:descriptor]] = @descriptors_hash[d_key][:observations][otu_collection_object]
          end
        end
      end
      if r_value[:errors] > @error_tolerance
        r_value[:status] = 'eliminated'
      else
        h[r_value[:object_at_rank]] = true if h[r_value[:object_at_rank]].nil?
      end
    end
    return h
  end

  def eliminated_taxa
    h = {}
    @row_hash.each do |r_key, r_value|
      if r_value[:status] == 'eliminated' && @ramaining[r_value[:object_at_rank]].nil?
        if h[r_value[:object_at_rank]].nil?
          h[r_value[:object_at_rank]] = {}
          h[r_value[:object_at_rank]][:error_descriptors] = {}
        end
        r_value[:error_descriptors].each do |e, o|
          h[r_value[:object_at_rank]][:error_descriptors][e] = o if h[r_value[:object_at_rank]][:error_descriptors][e].nil?
        end
      end
    end
    return h
  end

  def useful_descriptors
    list_of_remaining_taxa = {}
    language = @language_id.blank? ? nil : @language_id.to_i
    @row_hash.each do |r_key, r_value|
      if r_value[:status] != 'eliminated' && r_value[:status] != 'used'
        list_of_remaining_taxa[r_value[:object_at_rank] ] = true
      end
    end
    number_of_taxa = list_of_remaining_taxa.count
    array_of_descriptors = []

    @descriptors_hash.each do |d_key, d_value|
      taxa_with_unknown_character_states = list_of_remaining_taxa if @eliminate_unknown == false
      d_value[:observations].each do |otu_key, otu_value|
        otu_collection_object = otu_key
        if @row_hash[otu_collection_object][:status] != 'eliminated'
          otu_value.each do |o|
            if o.character_state_id
              d_value[:state_ids][o.character_state_id.to_s] = {} if d_value[:state_ids][o.character_state_id.to_s].nil?
              d_value[:state_ids][o.character_state_id.to_s][:rows] = {} if d_value[:state_ids][o.character_state_id.to_s][:rows].nil? ## rows which this state identifies
              d_value[:state_ids][o.character_state_id.to_s][:rows][ @row_hash[otu_collection_object][:object_at_rank] ] = true
              d_value[:state_ids][o.character_state_id.to_s][:status] = 'useful' ## 'used', 'useful', 'useless'
            end
            unless o.presence.nil?
              d_value[:state_ids][o.presence.to_s] = {} if d_value[:state_ids][o.presence.to_s].nil?
              d_value[:state_ids][o.presence.to_s][:rows] = {} if d_value[:state_ids][o.presence.to_s][:rows].nil? ## rows which this state identifies
              d_value[:state_ids][o.presence.to_s][:rows][ @row_hash[otu_collection_object][:object_at_rank] ] = true
              d_value[:state_ids][o.presence.to_s][:status] = 'useful' ## 'used', 'useful', 'useless'
            end
            unless o.continuous_value.nil?
              d_value[:state_ids][o.id] = true
            end
            unless o.sample_min.nil?
              d_value[:state_ids][o.id] = {o_min: o.sample_min, o_max: o.sample_max}
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
          state[:status] = 'usefull'
          n = s_value[:rows].count
          if n == number_of_taxa || n == 0
            s_value[:status] = 'useless'
            state[:status] = 'useless'
          else
            d_value[:status] = 'useful'
            descriptor[:status] = 'useful'
          end
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
        number_of_measurements = d_value[:state_ids].count
        s = (d_value[:min] - (d_value[:min] / 10)) / (d_value[:max] - d_value[:min])
        descriptor[:usefulness] = number_of_taxa * s * (2 - (number_of_measurements / number_of_taxa))
      when 'Descriptor::Sample'
        descriptor[:default_unit] = d_value[:descriptor].default_unit
        descriptor[:min] = d_value[:min]
        descriptor[:max] = d_value[:max]
        number_of_measurements = d_value[:state_ids].count
        #                               i = max - min ; if 0 then (numMax - numMin / 10)
        #                               sum of all i
        #                               if numMax = numMin then numMax = numMax + 0.00001
        #                               weight = rem_taxa * (sum of i / number of measuments for taxon / (numMax - numMin) ) * (2 - number of measuments for taxon / rem_taxa)
        d_value[:state_ids].each do |s_key, s_value|
          if s_value[:o_min] == s_value[:o_max] || s_value[:o_max].blank?
            s += (s_value[:o_max] || s_value[:o_min] - s_value[:o_min]) / number_of_measurements / (d_value[:max] || d_value[:min] - d_value[:min])
          else
            s += (s_value[:o_min] - (s_value[:o_min] / 10)) / number_of_measurements / (d_value[:max] || d_value[:min] - d_value[:min])
          end
        end
        descriptor[:usefulness] = number_of_taxa * s * (2 - (number_of_measurements / number_of_taxa))

      when 'Descriptor::PresenceAbsence'
        number_of_states = 2
        descriptor[:states] = []
        d_value[:state_ids].each do |s_key, s_value|
          state = {}
          state[:name] = s_key
          state[:number_of_objects] = s_value[:rows].count + number_of_taxa_with_unknown_character_states
          state[:status] = 'usefull'
          n = s_value[:rows].count
          if n == number_of_taxa || n == 0
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

      array_of_descriptors += [descriptor]
    end

    case @sorting
    when 'ordered'
      array_of_descriptors.sort_by!{|i| i[:position]}
    when 'weighed'
      array_of_descriptors.sort_by!{|i| [-i[:weight], i[:usefulness]] }
    when 'optimized'
      array_of_descriptors.sort_by!{|i| i[:usefulness]}
    end

  end

  def observations
    # id
    # descriptor_id
    # otu_id
    # collection_object_id
    # character_state_id
    # continuous_value
    # continuous_unit
    # sample_min
    # sample_max
    # sample_unit
    # presence
    # description
    # cached
    # cached_column_label
    # cached_row_label
    # description
    # type
    ### types: Qualitative(char_states); Presence absence; Quantitative (single measurement); Sample (min, max); Free text
  end


=begin
  not numeric
  weight = rem_taxa/number_of_states + squer (sum (rem_taxa/number_of_states - taxa_in_each_state)^2)

  numeric for each measurement for a particular species
                                 i = max - min ; if 0 then (numMax - numMin) / 10
                                 sum of all i
                                 if numMax = numMin then numMax = numMax + 0.00001
                                 weight = rem_taxa * (sum of i / number of measuments for taxon / (numMax - numMin) ) * (2 - number of measuments for taxon / rem_taxa)
=end

  # rst = All characters ordered by Characters.Weight DESC, Characters.Char, State.State"
  # rst2 = List of all taxa from the key ordered by hiercode
  # filter = taxa with specic IDs
  # list of used states
  # count the number of errors for each taxon
end

=begin


' Save all used characters and their states into array charUsed()

CharMax = 0
Do Until rst.EOF
  i = CStr(rst("Char"))
  j = CStr(rst("State"))
  r = replace(CStr(Request("a" & i)), " ", "")
  r = replace(r, "aa", "a")
  if (r = j and multistates = "") or (rst("Numeric") = True and r <> "" and isNumeric(left(r, inStr(r & "-", "-") - 1)) and isNumeric(right(r, len(r) - inStr(r, "-")))) then
    charMax = charMax + 1
    charUsed(charMax, 1) = i
    charUsed(charMax, 2) = r
    charUsed(charMax, 3) = CStr(request("n" & i))
    if charUsed(charMax, 3) = "1" then
      states = states & "-" & rst("Key2")
    else
      states = states & rst("Key2")
    end if
    if rst("Numeric") = True then
      states = states & "-" & r & "b"
    else
      states = states & "b"
    end if
    where2 = where2 & " OR Char=" & i
  elseif multistates = "1" and rst("Numeric") = False then
    m = CStr(Request("m" & i))
    if (inStr(m, "!") = 0 and inStr(m, "a" & j & "a") > 0) or (m = "" and r = j) or (inStr(m, "!") = 1 and ((inStr(m, "a" & j & "a") > 0 and inStr(m, "a" & r & "a") > 0) or (r = j and inStr(m, "a" & r & "a") = 0))) then
      if charUsed(charMax, 1) <> i then charMax = charMax + 1
      charUsed(charMax, 1) = i
      charUsed(charMax, 2) = charUsed(charMax, 2) & "a" & j & "a"
      charUsed(charMax, 3) = CStr(request("n" & i))
      if charUsed(charMax, 3) = "1" then
        states = states & "-" & rst("Key2") & "b"
      else
        states = states & rst("Key2") & "b"
      end if
      where2 = where2 & " OR Char=" & i
    end if
  end if
  rst.moveNext
Loop
rst.MoveFirst
if where2 & "" <> "" then where2 = "AND (" & right(where2, len(where2) - 4) & ") "

' Open recordset Matrix of characters

if keyN <> "" then where1 = "AND ','&CharTableTotal.KeyN&',' Like '%," & keyN & ",%' AND ','&CharTableTotal.CharKeyN&',' Like '%," & keyN & ",%' "
strSQL = "SELECT Morph, Char, State, Hiercode, Numeric, NumericFrom, NumericTo FROM CharTableTotal "
if cat = "1" then
  strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & where2 & "ORDER BY Morph, Weight DESC, Char, Hiercode, State"
else
  strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & where2 & "ORDER BY Weight DESC, Char, Hiercode, State"
end if
rst2.Open strSQL, Conn


if rst2.eof then ' Datamatrix is empty
  response.write "<p style='color: #FF0000'>The datamatrix is empty!</p>"
else

' Mark the taxa in array taxa() which does not fit to criteria (count number of errors)

for j = 1 to charMax
  for i = 1 to taxaMax
    if taxa(i, 2) <> "-1" then
      do until left(rst2("Hiercode"), len(taxa(i, 1))) = taxa(i, 1) and rst2("Char") & "" = charUsed(j, 1)
      rst2.MoveNext
    loop
    if multistates = "1" and rst2("Numeric") = False then
      if charUsed(j, 3) = "1" then ' character with not
        do until inStr(charUsed(j, 2), rst2("State")) = 0 or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
          rst2.MoveNext
          if rst2.EOF then exit do
        loop
      else
        do until inStr(charUsed(j, 2), rst2("State")) > 0 or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
          rst2.MoveNext
          if rst2.EOF then exit do
        loop
      end if
    else
      if charUsed(j, 3) = "1" then ' character with not
        do until (rst2("Numeric") = True and (rst2("NumericFrom") > cDbl(right(charUsed(j, 2), len(charUsed(j, 2)) - inStr(charUsed(j, 2), "-"))) or rst2("NumericTo") < cDbl(left(charUsed(j, 2), inStr(charUsed(j, 2) & "-", "-")-1)))) or (charUsed(j, 2) <> rst2("State") & "" and rst2("Numeric") = False) or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
          rst2.MoveNext
          if rst2.EOF then exit do
        loop
      else
        do until (rst2("Numeric") = True and rst2("NumericFrom") <= cDbl(right(charUsed(j, 2), len(charUsed(j, 2)) - inStr(charUsed(j, 2), "-"))) and rst2("NumericTo") >= cDbl(left(charUsed(j, 2), inStr(charUsed(j, 2) & "-", "-")-1))) or (charUsed(j, 2) = rst2("State") & "" and rst2("Numeric") = False) or (rst2("State") & "" = "" and unknowns <> "1") or left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1)
          rst2.MoveNext
          if rst2.EOF then exit do
        loop
      end if
    end if
    if rst2.EOF then
      taxa(i, 2) = taxa(i, 2) + 1
    elseIf left(rst2("Hiercode"), len(taxa(i, 1))) <> taxa(i, 1) then
      taxa(i, 2) = taxa(i, 2) + 1
    end if
    end if
  next
next

' Making query strings for lists of taxa

for t = 1 to taxaMax
  if CInt(taxa(t, 2)) <= tol and taxa(t, 2) <> "-1" then
    queryStr1 = queryStr1 & taxa(t, 0) & "a" & taxa(t, 2) & "a"
    if CInt(taxa(t, 2)) < tol then taxaRemTol = taxaRemTol + 1
    taxaRem = taxaRem + 1
  else
    queryStr2 = queryStr2 & taxa(t, 0) & "a" & taxa(t, 2) & "a"
  end if
next
if len(queryStr1) > 0 then queryStr1 = states & left(queryStr1, len(queryStr1) - 1)
if len(queryStr2) > 0 then queryStr2 = states & left(queryStr2, len(queryStr2) - 1)

' Resort recordset rst2

rst2.Close
strSQL = "SELECT Morph, Char, State, Hiercode, Numeric, NumericFrom, NumericTo " &_
  "FROM CharTableTotal "
if cat = "1" then
  strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & "ORDER BY Morph, Weight DESC, Char, State, Hiercode"
else
  strSQL = strSQL & replace(where, "Characters", "CharTableTotal") & where1 & "ORDER BY Weight DESC, Char, State, Hiercode"
end if
rst2.Open strSQL, Conn

' Make the form with set of character

a = 1
t = 1
m = ""
j = rst("Char") & ""
Do Until rst.EOF
  if rank <> "" then
    for i = 1 to taxaMax
      taxa(i, 3) = "0"
    next
  end if
  i = rst("Char") & ""
  morphN = rst("Morph")
  charName = charReplace(rst("Char" & lng))

  descr = rst("Descr" & lng) & ""

  if not rst2.eof then
    Do Until rst2("Char") & "" = i
      rst2.MoveNext
      if rst2.EOF then exit do
    Loop
  end if

  if not rst2.eof then
    fig = 0
    weight = rst("Weight") & ""
    CharTemp1 = ""
    if weight <> "" then weight = ", I=" & weight
    usefull = 0
    stUnknown = 0
    stNum = 0
    stSum = 0
    numMin = 9999999
    numMax = -9999999

    if rst("Numeric") = False then ' !!!!!!!!!!Not Numeric!!!!!!!!!
      if multistates = "1" then
        m = request("m" & i) & ""
        if (inStr(m, "!") = 1 and inStr(m, "a" & Request("a" & i) & "a") > 0) or (m <> "" and inStr(m, "!") <> 1) then
          m = Replace("<input type='hidden' name='m" & i & "' value='!" & Replace(m, "!", "") & "'>", "'!'", "''") & sp
      else
        m = "<input type='hidden' name='m" & i & "' value=''>" & sp
      end if
      end if
    if charUsed(a, 1) & "" <> i then
      CharTemp = "<li><b>" & charName & "</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & m & "not&nbsp;<input type=checkbox name='n" & i & "' value='1'>&nbsp;<select name='a" & i & "'>" & sp & "<option value='" & "' selected> </option>" & sp
    else
      CharTemp = "<li><b>" & charName & "</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & m & "not&nbsp;<input type=checkbox " & replace(charUsed(a,3), "1", "checked ") & "name='n" & i & "' value='1'>&nbsp;<select name='a" & i & "'>" & sp & "<option value='" & "'> </option>" & sp
    end if

    hc = 0
    if not rst2.eof then
      Do Until rst2("Char") & "" <> i or rst2("State") & "" <> ""
        z = 0
        Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
          t = t + 1
          if t > taxaMax then
            t = 1
            z = z + 1
            if z > 1 then exit Do
          end if
        Loop
        if CInt(taxa(t, 2)) = tol and hc <> taxa(t, 1) and z < 2 then
          if rank <> "" then taxa(t, 3) = "1"
          stUnknown = stUnknown + 1
          hc = taxa(t, 1)
        end if
        rst2.MoveNext
        if rst2.eof then exit do
      Loop
    end if

    if unknowns = "1" then stUnknown = 0
    Do until j <> i
      stCount = stUnknown
      if not rst2.EOF then
        r = rst("State") & ""
        hc = 0
        Do Until rst2("Char") & "" <> i or rst2("State") & "" <> r
          z = 0
          Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
            t = t + 1
            if t > taxaMax then
              t = 1
              z = z + 1
              if z > 1 then exit Do
            end if
          Loop
          if CInt(taxa(t, 2)) = tol and hc <> taxa(t, 1) and taxa (t, 3) <> "1" and z < 2 then
            stCount = stCount + 1
            hc = taxa(t, 1)
          end if
          rst2.MoveNext
          if rst2.EOF then Exit Do
        Loop
      end if
      stCount = stCount + taxaRemTol
      if stCount > 0 and stCount < taxaRem Then
        stNum = stNum + 1
        strCharArr(stNum, 0) = stCount
      end if

      if charUsed(a, 1) = i and (inStr(charUsed(a, 2) , "a" & r & "a") = 1 or charUsed(a, 2) = r) then
        CharTemp = CharTemp + "<option value='" & rst("State") & "' selected>&gt; " & charReplace(rst("State" & lng)) & "</option>" & sp
      elseif charUsed(a, 1) = i and inStr(charUsed(a, 2) & "", "a" & r & "a") > 1 then
        CharTemp = CharTemp + "<option value='" & rst("State") & "'>&gt; " & charReplace(rst("State" & lng)) & "</option>" & sp
      elseIf charUsed(a, 1) = i and charUsed(a, 2) <> r then
        CharTemp = CharTemp + "<option value='" & rst("State") & "'>" & charReplace(rst("State" & lng)) & "</option>" & sp
      else
        if stCount = 0 or stCount = taxaRem then
          CharTemp = CharTemp + "<option value='" & rst("State") & "'>- " & charReplace(rst("State" & lng)) & " ("&stCount&") -</option>" & sp
        else
          CharTemp = CharTemp + "<option value='" & rst("State") & "'>" & charReplace(rst("State" & lng)) & " ("&stCount&")</option>" & sp
          usefull = 1
        end if
        CharTemp1 = CharTemp1 & "&a" & rst("State") & "=" & stCount
      end if
      if rst("Fig") & "" <> "" then fig = 1

      rst.MoveNext
      if rst.EOF then
        exit do
      else
        j = rst("Char") & ""
      end if
    Loop
    CharTemp1 = CharTemp1 & "&b=" & taxaRem
    CharTemp = CharTemp + "</select>" & sp & sp
    If fig = 1 or descr <> "" or multistates = "1" then
      opt = len(CharTemp) - len(replace(CharTemp, "option", ""))
      if fig = 1 and multistates = "1" then opt = opt + 12
      if opt > 90 and fig = 1 then
        CharTemp = replace(CharTemp, ">" & charName & "<", "><a href=""" & "javascript:makeHelpWindow('" & i & CharTemp1 & "',800,600)""" & " Title='" & show & "'>" & charName & "</a><")
      elseIf opt > 50 or (multistates = "1" and fig = 1) then
        CharTemp = replace(CharTemp, ">" & charName & "<", "><a href=""" & "javascript:makeHelpWindow('" & i & CharTemp1 & "',640,480)""" & " Title='" & show & "'>" & charName & "</a><")
      elseIf opt < 50 then
        CharTemp = replace(CharTemp, ">" & charName & "<", "><a href=""" & "javascript:makeHelpWindow('" & i & CharTemp1 & "',640,300)""" & " Title='" & show & "'>" & charName & "</a><")
      end if
    end if

    else ' !!!!!!!Numeric!!!!!!!!

    if not rst2.eof then
      hc = 0
      Do Until rst2("Char") & "" <> i or rst2("State") & "" <> ""
        z = 0
        Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
          t = t + 1
          if t > taxaMax then
            t = 1
            z = z + 1
            if z > 1 then exit do
          end if
        Loop
        if CInt(taxa(t, 2)) = tol and hc <> taxa(t, 1) and z < 2 then
          if rank <> "" then taxa(t, 3) = "1"
          stUnknown = stUnknown + 1
          hc = taxa(t, 1)
        end if
        rst2.MoveNext
        if rst2.eof then exit do
      Loop
    end if

    usefull = 0
    if not rst2.eof then
      stCount = 0
      hc = 0
      do until rst2("Char") & "" <> i
        z = 0
        Do Until left(rst2("Hiercode"), len(taxa(t, 1))) = taxa(t, 1)
          t = t + 1
          if t > taxaMax then
            t = 1
            z = z + 1
            if z > 1 then exit Do
          end if
        Loop
        if CInt(taxa(t, 2)) = tol and z < 2 then
          if hc <> taxa(t, 1) and taxa(t, 3) <> "1" then
            hc = taxa(t, 1)
            stNum = stNum + 1
            strCharArr(stNum, 0) = rst2("NumericTo")
            strCharArr(stNum, 4) = rst2("NumericFrom")
          end if
          if strCharArr(stNum, 0) > rst2("NumericTo") then strCharArr(stNum, 0) = rst2("NumericTo")
          if strCharArr(stNum, 4) < rst2("NumericFrom") then strCharArr(stNum, 4) = rst2("NumericFrom")
          if numMin > rst2("NumericFrom") then
            if numMin < 9999999 then usefull = 1
            numMin = rst2("NumericFrom")
          end if
          if numMax < rst2("NumericTo") then
            if numMax > -9999999 then usefull = 1
            numMax = rst2("NumericTo")
          end if
          stCount = 1
        end if
        rst2.moveNext
        if rst2.eof then exit do
      loop
    end if
    if charUsed(a, 1) & "" <> i then
      if numMin = 9999999 then
        charTemp1 = ""
      elseIf numMin = numMax then
        charTemp1 = numMin & " "
      else
      CharTemp1 = numMin & "-" & numMax & " "
      end if
      CharTemp = "<li><b>" & charName & " [" & charTemp1 & charReplace(rst("State" & lng)) & "]</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & "not&nbsp;<input type=checkbox name='n" & i & "' value='1'>&nbsp;<input type='text' name='a" & i & "' value='' size='15'>" & sp
    else
      CharTemp = "<li><b>" & charName & " [" & charReplace(rst("State" & lng)) & "]</b> (" & UCase(rst("Type")) & weight & ")<br>" & sp & "not&nbsp;<input type=checkbox " & replace(charUsed(a,3), "1", "checked ") & "name='n" & i & "' value='1'>&nbsp;<input type='text' name='a" & i & "' value='" & charUsed(a, 2) & "' size='15'>" & sp
    end if
    If rst("fig") & "" <> "" or descr <> "" then
      CharTemp = replace(CharTemp, ">" & charName & " [" & charTemp1 & charReplace(rst("State" & lng)) & "]<", "><a href=""" & "javascript:makeHelpWindow('" & i & "',640,280)""" & " Title='" & show & "'>" & charName & "</a> [" & charTemp1 & charReplace(rst("State" & lng)) & "]<")
    end if

    rst.MoveNext
    if not rst.EOF then j = rst("Char") & ""

    end if ' !!!!!!!!!Numeric!!!!!!!!!!
  end if

  if charUsed(a, 1) = i then
    strChar2 = strChar2 + CharTemp
    a = a + 1
  ElseIf usefull = 0 then
    strChar3 = strChar3 & CharTemp
  Else
    if taxaRem > 1 then
      if cat = "1" and rst1("Morph") <> morphN then
        Do until rst1("Morph") = morphN
          rst1.moveNext
        Loop
        morph = 0
      end if
      if cat = "1" and rst1("Morph") = morphN and morph <> 1 then
        l = Replace(rst1("Morph" & lng), " ", "&nbsp;")
        strChar1 = strChar1 & "<br><br><a name='" & l & "'></a><span class='a'>" & l & "</span><br><br>" & sp & sp
        link = link & "<a href='#" & l & "'>" & l & "</a>&nbsp;| " & sp
        morph = 1
      end if
      if cat <> "1" then
        if numMin = 9999999 then stMed = taxaRem / stNum else stMed = taxaRem
        For i1 = 1 to stNum
          if numMin = 9999999 then
            stSum = stSum + ((stMed) - strCharArr(i1, 0)) ^ 2
          else
            strCharArr(i1, 0) = strCharArr(i1, 4) - strCharArr(i1, 0)
            if strCharArr(i1, 0) = 0 then strCharArr(i1, 0) = (numMax - numMin) / 10
            stSum = stSum + strCharArr(i1, 0)
          end if
        Next
        strCharMax = strCharMax + 1
        if numMax = numMin then numMax = numMax + 0.00001
        if numMin = 9999999 then
          strCharArr(strCharMax, 2) = stMed + Sqr(stSum)
        else
          strCharArr(strCharMax, 2) = stMed * (stSum / stNum / (numMax - numMin)) * (2 - stNum / taxaRem)
        end if
        strCharArr(strCharMax, 1) = CharTemp ' & strCharArr(strCharMax, 2) '!!!!!!!!!!!!!!!!
        strCharArr(strCharMax, 3) = CLng("0" & replace(weight, ", I=", ""))
      else
        strChar1 = strChar1 & CharTemp
      end if
    else
      strChar3 = strChar3 & CharTemp
    End if
  End if
Loop

' Outputtin form

%>
<body>
<script type="text/javascript">
<!--
window.onerror = null;

if (window.parent.window.length != 4)
  { window.location = ""; }
else {

window.parent.window.frames['taxa1'].window.document.forms['mainform'].elements['taxa'].value='<% =queryStr1 %>';
window.parent.window.frames['taxa1'].window.document.forms['mainform'].elements['lng'].value='<% =lng %>';
window.parent.window.frames['taxa1'].window.document.forms['mainform'].submit();
<% if tax = "1" then %>
  window.parent.window.frames['taxa2'].window.document.forms['mainform'].elements['taxa'].value='<% =queryStr2 %>';
  window.parent.window.frames['taxa2'].window.document.forms['mainform'].elements['lng'].value='<% =lng %>';
  window.parent.window.frames['taxa2'].window.document.forms['mainform'].submit();
<% end if %>
}
window.onfocus = ppHide;
var ww = null;

window.onclose = ppHide;

function makeHelpWindow(n,w,h)
{
if (navigator.appName == "Microsoft Internet Explorer")
<%
  Response.write "{ ww = window.open('charhelp.asp?key=" & key & "&lng=" & lng & "&m=" & multistates & "&keyN=" & keyN & "&ch=' + n,'_blank','scrollbars=" & scroll & ",resizable=no,width=' + w + ',height=' + h + ',top=' + (screen.availHeight - h) / 2 + ',left=' + (screen.availWidth - w) / 2 ); }"
%>
else
<%
  Response.write "{ ww = window.open('charhelp.asp?key=" & key & "&lng=" & lng & "&m=" & multistates & "&keyN=" & keyN & "&ch=' + n,'_blank','scrollbars=yes,resizable=yes,width=' + w + ',height=' + h + ',top=' + (screen.availHeight - h) / 2 + ',left=' + (screen.availWidth - w) / 2 ); }"
%>
}

function ppHide()
{ if(ww != null) ww.close(); ww=null;}

//-->
</script>

<%

if len(link) > 9 then
  link = left(link, len(link)-9)
end if %>

<form method='POST' action='char.asp' name='mainform'>

<input type="hidden" name="sex" value="<% =sex %>">
<input type="hidden" name="char" value="<% =char %>">
<input type="hidden" name="tax" value="<% =tax %>">
<input type="hidden" name="cat" value="<% =cat %>">
<input type="hidden" name="tol" value="<% =tol %>">
<input type="hidden" name="key" value="<% =key %>">
<input type="hidden" name="keyN" value="<% =keyN %>">
<input type="hidden" name="visit" value="<% =visit %>">
<input type="hidden" name="lng" value="<% =lng %>">
<input type="hidden" name="rank" value="<% =rank %>">
<input type="hidden" name="unknowns" value="<% =unknowns %>">
<input type="hidden" name="filter" value="<% =filter %>">
<input type="hidden" name="multistates" value="<% =multistates %>">
<%
if cat <> "1" and strCharMax > 1 then
For i = 1 to strCharMax - 1
For j = i + 1 to strCharMax
if strCharArr(i, 3) > strCharArr(j, 3) and cat = "0" then exit for
                                                               if strCharArr(i, 2) > strCharArr(j, 2) then
                                                                 CharTemp = strCharArr(i, 1)
                                                                 strCharArr(i, 1) = strCharArr(j, 1)
                                                                 strCharArr(j, 1) = CharTemp
                                                                 CharTemp = strCharArr(i, 2)
                                                                 strCharArr(i, 2) = strCharArr(j, 2)
                                                                 strCharArr(j, 2) = CharTemp
                                                               end if
      Next
  strChar1 = strChar1 + strCharArr(i, 1)
  Next
  strChar1 = strChar1 + strCharArr(strCharMax, 1)
  elseIf cat = "2" or strCharMax = 1 then
  strChar1 = strChar1 + strCharArr(1, 1)
                                                               end if
    if strChar2 & "" <> "" or filter <> "" then
      response.write "<div class='a'><ul>" & sp
      if strChar1 & "" <> "" then
        response.write "<li><a href='#useful'>" & rst3("Useful") & "</a>" & sp
        if len(link) > 0 then
          response.write "<br>" & sp & "(" & link & ")" & sp & sp
        end if
      end if
          if strChar3 & "" <> "" and char = "1" then
            response.write "<li><a href='#useless'>" & rst3("Relevant") & "</a>" & sp
          end if
          response.write "</ul></div>" & sp & sp
    end if


    if strChar2 & "" <> "" then
      response.Write sp & "<a Name='used'></a>" & sp & "<h2>" & rst3("Used") & "</h2>" & sp & sp
    end if
    if filter <> "" then
      if strChar2 & "" = "" then response.Write sp & "<a Name='used'></a>" & sp & "<h2>" & rst3("Used") & "</h2>" & sp & sp
      response.write "<p style='margin-bottom: 1em'><input type=checkbox checked name='f' value='1'>&nbsp;<b>Filter</b><br></p>" & sp & sp
      else
        response.write "<input type=hidden name='f' value=''>" & sp & sp
      end if
          if strChar2 & "" <> "" then
            response.write "<div class='a'><ol>" & sp & sp & strChar2 & "</ol></div>" & sp
          end if
          if strChar1 & "" <> "" then
            response.Write sp & "<a Name='useful'></a>" & sp & "<h2>" & rst3("Useful") & "</h2>" & sp & sp & "<p style='margin-bottom: 0em' align='center'>" & sp & link & sp & "</p>" & sp & sp & "<div class='a'><ol>" & sp & sp & strChar1 & "</ol></div>" & sp
          end if
          if strChar3 & "" <> "" and char = "1" then
            response.Write sp & "<a Name='useless'></a>" & sp & "<h2>" & rst3("Relevant") & "</h2>" & sp & sp & "<div class='a'><ol>" & sp & sp & strChar3 & "</ol></div>" & sp
          end if


          function charReplace(string)
      Do
      if inStr(string, "[") > 0 and inStr(string, "]") - inStr(string, "[") > 0 then
        string = trim(left(string, inStr(string, "[")-1) & right(string, len(string) - inStr(string, "]")))
      else
        Exit Do
      end if
          Loop
      string = replace(string & "", "{", "")
      string = replace(string, "}", "")
      string = replace(string, " & ", " &amp; ")
      if inStr(string & "<", "<") < inStrRev(">" & string, ">") and inStr(string, "</") > 0 then
      else
        string = replace(string, "<", "&lt;")
        string = replace(string, ">", "&gt;")
      end if
          charReplace = string
    end function

rst3.Close
Set rst3 = Nothing

end if ' Datamatrix is empty
=end
