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
    parse_nexus_file(f)
  end
end
