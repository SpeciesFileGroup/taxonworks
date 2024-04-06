module Vendor::NexusParser
  def self.document_to_nexus(doc)
    # Remove any cache buster.
    fname = doc.document_file.url.split('?').first
    f = File.read(Rails.root.join('public', *fname.split('/')))
    begin
      parse_nexus_file(f)
    rescue NexusParser::ParseError
      raise
    end
  end
end
