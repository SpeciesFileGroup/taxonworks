@options[:target] = xml


# Nexml.serialize(target: xml, observation_matrix: @observation_matrix, transform: false)

xml.instruct!

xml.nex(:nexml,
'version'            => '0.9',
'generator'          => 'TaxonWorks',
'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
'xmlns:xml'          => 'http://www.w3.org/XML/1998/namespace',
'xmlns:nex'          => 'http://www.nexml.org/2009',
'xmlns'              => 'http://www.nexml.org/2009',
'xsi:schemaLocation' => 'http://www.nexml.org/2009 ../xsd/nexml.xsd',
'xmlns:xsd'          => 'http://www.w3.org/2001/XMLSchema',
'xmlns:dc'           => 'http://purl.org/dc/terms/',
'xmlns:dwc'          => 'http://rs.tdwg.org/dwc/terms/',
'xmlns:foaf'         => 'http://xmlns.com/foaf/0.1/',
'xmlns:xi'           => 'http://www.w3.org/2003/XInclude' # IS THIS NECESSARY?
) do

  nexml_otus(@options) if @options[:include_otus] == 'true'  #   true  #if params[:include_otus]
  nexml_descriptors(@options) if @options[:include_descriptors] == 'true'  # if params[:include_descriptors]

  # This block format is not supported, they are presently rendered inline
  # nexml_depictions(@options) if true # @options[:include_depictions] == 'true'  # if params[:include_descriptors]
  # include_trees(opt) if opt[:include_trees]
end # end document


