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

    fixup_and_validate_characters_and_states(nf.characters,
      doc.document_file_file_name)

    nil_squish_strip_names(nf)

    nf
  end

  # Raises on error
  def self.fixup_and_validate_characters_and_states(characters, file_name)
    characters.each_with_index do |c, i|
      if c.name.nil? || c.name == 'Undefined' # nexus_parser special string
        c.name = "Undefined (#{i + 1}) from (#{file_name})"
      end

      # It shouldn't be possible to have duplicate state labels (right?) since
      # they're assigned sequentially, but nexus_parser does allow duplicate
      # and empty state names.
      state_names = []
      c.states.each do |label, state|
        if state.name == ''
          state.name = "Undefined (#{label}) from (#{file_name})"
        end
        state_names << state.name
      end

      dup_names = find_duplicates(state_names)
      if dup_names.present?
        dups = dup_names.join(', ')
        raise TaxonWorks::Error, "Error in character #{i + 1}: duplicate state name(s): '#{dups}'. In TaxonWorks character state names must be unique for a given descriptor."
      end
    end
  end

  # Assign name 'gap' to all gap states - nexus_parser outputs gap states that
  # have no name, but TW requires a name. Raises on error.
  def self.assign_gap_names(nf)
    gap_label = nf&.vars[:gap]
    if gap_label.nil?
      return
    end

    nf.characters.each_with_index do |c, i|
      if c.state_labels.include? gap_label
        c.states[gap_label].name = gap_name_for_states(c.states, i)
      end
    end
  end

  def self.gap_name_for_states(states, i)
    state_names = states.map { |k, v| v.name }
    if !state_names.include?('gap')
      return 'gap'
    else
      raise TaxonWorks::Error, "Nexus character #{i + 1} contains a gap state and a character state named 'gap', please rename the character state"
    end
  end

  # TW squishes names before saving to the db, incoming nexus names are
  # unsquished - squish incoming so they match what might already be in the db.
  def self.nil_squish_strip_names(nf)
    nf.characters.each { |c|
      c.name = Utilities::Rails::Strings.nil_squish_strip(c.name)

      c.states.keys.each { |k|
        c.states[k].name =
          Utilities::Rails::Strings.nil_squish_strip(c.states[k].name)
      }
    }

    nf.taxa.each { |t|
      t.name = Utilities::Rails::Strings.nil_squish_strip(t.name)
    }
  end

  def self.find_duplicates(arr)
    # https://stackoverflow.com/a/786976
    s = Set.new
    dups = Set.new
    arr.each { |o| dups.add(o) unless s.add?(o) }

    dups.to_a
  end

end
