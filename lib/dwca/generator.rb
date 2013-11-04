module Dwca::Generator
  
  # Generates a DwC-A from database data  
  def self.get_archive
    path = Rails.root.join('tmp/dwc_' + SecureRandom.hex + '.tar.gz')
    gen = DarwinCore::Generator.new(path)
    
    core = [["http://rs.tdwg.org/dwc/terms/taxonID"]]
    gen.add_core(core, 'core.txt')
    gen.add_meta_xml
    gen.pack
    gen.clean
    
    return path
  end
end
