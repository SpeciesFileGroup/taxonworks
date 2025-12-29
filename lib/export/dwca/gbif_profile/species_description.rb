# Species Description extension class
# Repository: http://rs.gbif.org/extension/gbif/1.0/description.xml

module Export::Dwca::GbifProfile

  class SpeciesDescription
    # Field name constants
    TAXON_ID = :taxonID
    TYPE = :type
    DESCRIPTION = :description
    SOURCE = :source
    LANGUAGE = :language
    CREATOR = :creator
    CONTRIBUTOR = :contributor
    AUDIENCE = :audience
    LICENSE = :license
    RIGHTS_HOLDER = :rightsHolder

    # Namespace mappings
    NAMESPACES = {
      TAXON_ID => 'http://rs.tdwg.org/dwc/terms/taxonID',
      TYPE => 'http://purl.org/dc/terms/type',
      DESCRIPTION => 'http://purl.org/dc/terms/description',
      SOURCE => 'http://purl.org/dc/terms/source',
      LANGUAGE => 'http://purl.org/dc/terms/language',
      CREATOR => 'http://purl.org/dc/terms/creator',
      CONTRIBUTOR => 'http://purl.org/dc/terms/contributor',
      AUDIENCE => 'http://purl.org/dc/terms/audience',
      LICENSE => 'http://purl.org/dc/terms/license',
      RIGHTS_HOLDER => 'http://purl.org/dc/terms/rightsHolder'
    }.freeze

    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this description record points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor TAXON_ID # [USED IN SF]

    # type (http://purl.org/dc/terms/type)
    #
    # @return [String]
    # The kind of description given. See the Description Type vocabulary at
    # http://rs.gbif.org/vocabulary/gbif/description_type.xml for a possible
    # list of description types.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/description_type.xml
    #
    # Example: "morphology", "distribution", "diagnostic"
    attr_accessor TYPE # [USED IN SF]

    # description (http://purl.org/dc/terms/description)
    #
    # @return [String]
    # Any descriptive free text matching the category given by the type
    attr_accessor DESCRIPTION # [USED IN SF]

    # source (http://purl.org/dc/terms/source)
    #
    # @return [String]
    # Source reference of this description; a URL or full publication citation
    attr_accessor SOURCE

    # language (http://purl.org/dc/terms/language)
    #
    # @return [String]
    # ISO 639-1 language code used for the vernacular name value.
    #
    # Example: "ES", "Spanish", "Español"
    attr_accessor LANGUAGE

    # creator (http://purl.org/dc/terms/creator)
    #
    # @return [String]
    # The author(s) of the textual information provided for a description
    #
    # Example: "Hershkovitz, P."
    attr_accessor CREATOR

    # contributor (http://purl.org/dc/terms/contributor)
    #
    # @return [String]
    # An entity responsible for making contributions to the textual information
    # provided for a description
    attr_accessor CONTRIBUTOR

    # audience (http://purl.org/dc/terms/audience)
    #
    # @return [String]
    # A class or description for whom the dwc:description is intended or useful
    #
    # Example: "experts", "general public", "children"
    attr_accessor AUDIENCE

    # license (http://purl.org/dc/terms/license)
    #
    # @return [String]
    # Official permission to do something with the resource. Please use
    # Creative Commons URIs if you can.
    #
    # Example: CC-BY
    attr_accessor LICENSE

    # rightsHolder (http://purl.org/dc/terms/rightsHolder)
    #
    # @return [String]
    # A person or organization owning or managing rights over the resource.
    attr_accessor RIGHTS_HOLDER
  end
  
end