module Vendor::NexusParser
  # Can raise ActiveRecord::RecordNotFound and NexusParser::ParseError
  def self.document_id_to_nexus(doc_id)
    nexus_doc = Document.find(doc_id)
    document_to_nexus(nexus_doc)
  end

  # Can raise NexusParser::ParseError
  def self.document_to_nexus(doc)
    # Remove any cache buster.
    fname = doc.document_file.url.split('?').first
    f = File.read(Rails.root.join('public', *fname.split('/')))
    nf = parse_nexus_file(f)

    assign_gap_names(nf)
  end

  # Assign a name to all gap states (nexus_parser outputs gap states that have
  # no name, but TW requires a name).
  # @param a nexus file object as returned by nexus_parser
  def self.assign_gap_names(nf)
    gap_label = nf&.vars[:gap]
    if gap_label.nil?
      return nf
    end

    nf.characters.each do |c|
      if c.state_labels.include? gap_label
        c.states[gap_label].name = gap_name_for_states(c.state_labels)
      end
    end

    nf
  end

  def self.gap_name_for_states(states)
    if !states.include?('gap')
      return 'gap'
    else
      i = 1
      while i < 1000 && states.include?("gap_#{i}")
        i = i + 1
      end
      return "gap#{i}"
    end
  end
end
