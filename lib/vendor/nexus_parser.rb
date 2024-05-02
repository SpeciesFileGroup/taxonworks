module Vendor::NexusParser
  # Raises on error
  def self.document_id_to_nexus(doc_id)
    nexus_doc = Document.find(doc_id)
    document_to_nexus(nexus_doc)
  end

  # Raises on error
  def self.document_to_nexus(doc)
    f = File.read(doc.document_file.path)
    nf = parse_nexus_file(f)

    assign_gap_names(nf)

    validate_characters_and_states(nf.characters)

    nf
  end

  def self.validate_characters_and_states(characters)
    characters.each_with_index do |c, i|
      if c.name == 'Undefined' # nexus_parser special string
        raise TaxonWorks::Error, "Character #{i + 1} has no name - in TaxonWorks descriptors are required to have a name."
      end

      # It shouldn't be possible to have duplicate state labels (right?) since
      # they're assigned sequentially, but nexus_parser does allow duplicate
      # and empty state names, which TW does not.
      state_names = c.states.map { |k, v| v.name }
      if (empty_index = state_names.index(''))
        raise TaxonWorks::Error, "Character #{empty_index + 1} contains an empty state name - in TaxonWorks all character states are required to have a name."
      end

      dup_names = find_duplicates(state_names)
      if dup_names.present?
        dups = dup_names.join(', ')
        raise TaxonWorks::Error, "Error in character #{i + 1}: duplicate name(s): '#{dups}'. In TaxonWorks character names must be unique for a given descriptor."

        return false
      end
    end

    true
  end

  # Assign name 'gap' to all gap states - nexus_parser outputs gap states that
  # have no name, but TW requires a name. Raises on error.
  def self.assign_gap_names(nf)
    gap_label = nf&.vars[:gap]
    if gap_label.nil?
      return nf
    end

    nf.characters.each_with_index do |c, i|
      if c.state_labels.include? gap_label
        c.states[gap_label].name = gap_name_for_states(c.states, i)
      end
    end

    nf
  end

  def self.gap_name_for_states(states, i)
    state_names = states.map { |k, v| v.name }
    if !state_names.include?('gap')
      return 'gap'
    else
      raise TaxonWorks::Error, "Nexus character #{i + 1} contains a gap state and a character state named 'gap', please rename the character state"
    end
  end

  def self.find_duplicates(arr)
    # https://stackoverflow.com/a/786976
    s = Set.new
    dups = Set.new
    arr.each { |o| dups.add(o) unless s.add?(o) }

    dups.to_a
  end

end
