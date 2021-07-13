# Contains methods used to build an otu description from the matrix
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

  # @!row_id
  #   @return [String or null]
  # Optional attribute to provide a rowID
  attr_accessor :row_id

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

  # @!generated_description
  #   @return [string]
  # Returns generated description for OTU
  attr_accessor :generated_description

  def initialize(
    observation_matrix_id: nil,
    project_id: nil,
    include_descendants: nil,
    language_id: nil,
    keyword_ids: nil,
    row_id: nil,
    otu_id: nil)

    # raise if observation_matrix_id.blank? || project_id.blank?
    @observation_matrix_id = observation_matrix_id
    @project_id = project_id
    @observation_matrix = find_matrix
    @include_descendants = include_descendants
    @language_to_use = language_to_use
    @descriptor_available_keywords = descriptor_available_keywords
    @descriptors_with_filter = descriptors_with_keywords
    @descriptor_available_languages = descriptor_available_languages
    @language_id = language_id
    @otu_id = otu_id
    @row_id = row_id
    @otu_id_filter_array = otu_id_array
    @collection_object_id_filter_array = collection_object_id_array
    ###main_logic
    @generated_description = get_description
    ###delete temporary data
    @descriptors_with_filter = nil
  end

  def find_matrix
    return nil if @observation_matrix_id.blank?
    ObservationMatrix.where(project_id: project_id).find(@observation_matrix_id)
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
    if @observation_matrix_id.blank?
      Descriptor.not_weight_zero.order(:position)
    else
      Descriptor.select('descriptors.*, observation_matrix_columns.position AS column_position').
        joins(:observation_matrix_columns).
        not_weight_zero.
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
    if !@row_id.blank?
      @otu_id = ObservationMatrixRow.find(@row_id.to_i)&.otu_id
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
    elsif !@row_id.blank?
      [ObservationMatrixRow.find(@row_id.to_i)&.collection_object_id.to_i]
    else
      [0]
    end
  end

  def get_description

    or_separator = ' or '

    descriptor_ids = @descriptors_with_filter.collect{|i| i.id}
    t = ['Observation::Continuous', 'Observation::PresenceAbsence', 'Observation::Sample']

    char_states = CharacterState.joins(:observations).
      where('character_states.descriptor_id IN (?) AND (otu_id IN (?) OR collection_object_id IN (?) )', descriptor_ids, @otu_id_filter_array, @collection_object_id_filter_array).
      uniq
    observations = Observation.where('observations.type IN (?) AND descriptor_id IN (?) AND (otu_id IN (?) OR collection_object_id IN (?) )', t, descriptor_ids, @otu_id_filter_array, @collection_object_id_filter_array).uniq

    descriptor_hash = {}
    @descriptors_with_filter.each do |d|
      descriptor_hash[d.id] = {}
      descriptor_hash[d.id][:descriptor] = d
      descriptor_hash[d.id][:char_states] = [] if d.type == 'Descriptor::Qualitative'
      descriptor_hash[d.id][:min] = 999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # min value used as continuous or sample
      descriptor_hash[d.id][:max] = -999999 if d.type == 'Descriptor::Continuous' || d.type == 'Descriptor::Sample' # max value used as continuous or sample
      descriptor_hash[d.id][:presence] = nil if d.type == 'Descriptor::PresenceAbsence'
    end
    char_states.each do |cs|
      descriptor_hash[cs.descriptor_id][:char_states].append(cs)
    end
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

    language = @language_id.blank? ? nil : @language_id.to_i
    str = ''
    descriptor_name = ''
    descriptor_hash.each do |d_key, d_value|
      next if (d_value[:descriptor].type == 'Descriptor::Qualitative' && d_value[:char_states].empty?) ||
        ((d_value[:descriptor].type == 'Descriptor::Continuous' || d_value[:descriptor].type == 'Descriptor::Sample') && d_value[:min] == 999999) ||
        (d_value[:descriptor].type == 'Descriptor::PresenceAbsence' && d_value[:presence].nil?)
      descriptor_name_new = d_value[:descriptor].target_name(:description, language).capitalize
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
        str += st_str.join(or_separator)
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







=begin
  def description_from_observation_matrix(observation_matrix_id, include_descendants: false)
    if rst1("DescriptionType") > 0 and rst1("DescriptionType") < 5 and autoDescription then
      if keyN <> "" then
        response.write "<h2>Diagnosis</h2>" & sp
        response.write "<p><a class='h1' href='diagnos.asp?key=" & key1 & "&lng=" & lng & "&hc=" & key & "&keyN=" & keyN & "&r=&title=" & Server.URLEncode(title) & "'>Generate Diagnosis</a></p>" & sp
      end if
        if rst1("DescriptionType") = 3 or rst1("DescriptionType") = 4 then
        where = "AND Characters.KeyN&'' Like '%" & KeyN & "%' "
        else
          where = ""
        end if

        rst.Close
      strSQL = "SELECT Taxon.Hiercode, Morph.Morph" & lng & ", Characters.Char" & lng & ", Characters.KeyN, Characters.Numeric, State.State" & lng & ", Morph.Morph, Characters.Char, State.State, CharTable.NumericFrom, CharTable.NumericTo " &_
      "FROM Taxon INNER JOIN ((Morph RIGHT JOIN (Characters INNER JOIN State ON Characters.Key1 = State.Key1) ON Morph.Morph = Characters.Morph) INNER JOIN CharTable ON State.Key2 = CharTable.Key2) ON Taxon.Key = CharTable.Key " &_
      "GROUP BY Taxon.Hiercode, Morph.Morph" & lng & ", Characters.Weight, Characters.Char" & lng & ", Characters.KeyN, State.State" & lng & ", Morph.Morph, Characters.Char, State.State, Characters.Numeric, CharTable.NumericFrom, CharTable.NumericTo " &_
      "HAVING Taxon.Hiercode Like '" & hc & "%' AND (Characters.Weight is Null or Characters.Weight Not Like '0') " & where &_
      "ORDER BY Morph.Morph, Characters.Char, State.State, CharTable.NumericFrom"
      rst.Open strSQL, Conn
      if not rst.EOF then
        response.write "<h2>" & rst1("Descript") & "</h2>" & sp
        morph = rst("Morph") & ""
        char = rst("Char")
        state = brackets(rst("State" & lng))
        i = 0
        stFrom = rst("NumericFrom")
        stTo = rst("NumericTo")
        response.write "<p>"
        if morph <> "" then response.write "<b>" & brackets(rst("Morph" & lng)) & ".</b> "
        if inStr(rst("State" & lng), "inapplicable") = 0 then
        text = brackets(rst("Char" & lng))
        char1 = ucase(left(text, 1)) & right(text, len(text) - 1)
        if rst1("DescriptionType") = 1 or rst1("DescriptionType") = 3 then response.write char1 & " "
        if rst("Numeric") = False then
        response.write state
        elseIf rst("NumericFrom") = rst("NumericTo") and rst("Hiercode") = hc then
        response.write rst("NumericFrom") & " " & state
        i = 1
        elseIf rst("Hiercode") = hc then
        response.write rst("NumericFrom") & "-" & rst("NumericTo") & " " & state
        i = 1
        end if
        end if ' inapplicable
    Do until rst.Eof
    text = brackets(rst("Char" & lng))
    char2 = ucase(left(text, 1)) & right(text, len(text) - 1)
    if char <> rst("Char") and stFrom > 0 then
      If stFrom = stTo and i = 0 then
      response.write stFrom & " " & state
      elseif i = 0 then
      response.write stFrom & "&#1038;¡ì§À&#1038;¡ì§ÀC" & stTo & " " & state
    end if
      stFrom = 0
    stTo = 0
    i = 0
  end if
    if morph <> rst("Morph") & "" then
      response.write ".</p>" & sp & "<p><b>" & brackets(rst("Morph" & lng)) & ".</b> "
      morph = rst("Morph") & ""
      elseIf char <> rst("Char") and char1 = char2 and inStr(rst("State" & lng), "inapplicable") = 0 then
      response.write ", "
      elseif char <> rst("Char") and inStr(rst("State" & lng), "inapplicable") = 0 then
      response.write ". "
    end if
    if state <> brackets(rst("State" & lng) & "") or stFrom & "a" & stTo <> rst("NumericFrom") & "a" & rst("NumericTo") or char <> rst("Char") then
      state = brackets(rst("State" & lng) & "")
      if inStr(rst("State" & lng), "inapplicable") = 0 then
      if char <> rst("Char") then
        text = char2
        if (rst1("DescriptionType") = 1 or rst1("DescriptionType") = 3) and char1 <> char2 then response.write char2 & " "
        char = rst("Char")
        char1 = char2
        orStr = ""
        i = 0
        else
          orStr = rst1("OrSeparator") & " "
        end if
          if rst("Numeric") = False then
          response.write orStr & state
          elseIf rst("Hiercode") = hc then
          If rst("NumericFrom") = rst("NumericTo") then
          response.write orStr & rst("NumericFrom") & " " & state
          else
            response.write orStr & rst("NumericFrom") & "-" & rst("NumericTo") & " " & state
          end if
          i = 1
      else
        if stFrom = 0 or stFrom > rst("NumericFrom") then stFrom = rst("NumericFrom")
        if stTo < rst("NumericTo") then stTo = rst("NumericTo")
        end if
        end if ' inapplicable
        end if
          rst.moveNext
        Loop
        if stFrom > 0 and i = 0 then
          If stFrom = stTo then
          response.write stFrom & " " & state
        else
          response.write stFrom & "&#1038;¡ì§À&#1038;¡ì§ÀC" & stTo & " " & state
        end if
          stFrom = 0
        stTo = 0
        end if
          response.write ".</p>" & sp
      end if
    end if
  end
=end
end
