# Alternate Identifiers extension class
# Repository: http://rs.gbif.org/extension/gbif/1.0/identifier.xml

module Dwca::GbifProfile

  class AlternateIdentifier
    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this identifier record points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor :taxonID

    # identifier (http://purl.org/dc/terms/identifier)
    #
    # @return [String]
    # External identifier used for the same taxon. Can be a URL pointing to a
    # webpage, an xml or rdf document, a DOI, UUID or any other identifer
    #
    # Example: “urn:lsid:ipni.org:names:692570-1:1.4”
    attr_accessor :identifier

    # title (http://purl.org/dc/terms/title)
    #
    # @return [String]
    # An optional display label for the URL that the publisher may prefer be
    # displayed with the identifier or link
    #
    # Example: "Danaus plexippus page", "COL Taxon LSID"
    attr_accessor :title

    # subject (http://purl.org/dc/terms/subject)
    #
    # @return [String]
    # keywords qualifying the identifier
    attr_accessor :subject

    # format (http://purl.org/dc/terms/format)
    #
    # @return [String]
    # Optional mime type of content returned by identifier in case the
    # identifier is resolvable. Plain UUIDs for example do not have a
    # dc:format return type, as they are not resolvable on their own. For a
    # list of MIME types see the list maintained by IANA:
    # http://www.iana.org/assignments/media-types/index.html, in
    # particular the text http://www.iana.org/assignments/media-types/text/
    # and application http://www.iana.org/assignments/media-types/application/
    # types. Frequently used values are text/html, text/xml, application/rdf+xml,
    # application/json
    #
    # Example: application/rdf+xml
    attr_accessor :format

  end

end