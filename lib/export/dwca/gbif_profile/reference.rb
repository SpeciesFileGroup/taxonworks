# References class
# Repository: http://rs.gbif.org/extension/gbif/1.0/references.xml

module Export::Dwca::GbifProfile

  class Reference
    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this reference record points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor :taxonID # [USED IN SF]

    # identifier (http://purl.org/dc/terms/identifier)
    #
    # @return [String]
    # DOI, ISBN, URI, etc refering to the reference. This can be repeated in
    # multiple rows to include multiple identifiers, e.g. a DOI and a URL
    # pointing to a pdf of the article.
    #
    # Example: doi:10.1038/ng0609-637;
    # http://www.nature.com/ng/journal/v41/n6/pdf/ng0609-637.pdf
    attr_accessor :identifier

    # bibliographicCitation (http://purl.org/dc/terms/bibliographicCitation)
    #
    # @return [String]
    # A text string referring to an un-parsed bibliographic citation.
    #
    # Example: “Hartge, P., Genetics of reproductive lifespan. Nature
    # Genetics 41, 637 - 638 (2009)”
    attr_accessor :bibliographicCitation # [USED IN SF]

    # title (http://purl.org/dc/terms/title)
    #
    # @return [String]
    # Title of book or article
    #
    # Example: "Genetics of reproductive lifespan", "Field Guide to Moths of
    # Eastern North America"
    attr_accessor :title # [USED IN SF]

    # creator (http://purl.org/dc/terms/creator)
    #
    # @return [String]
    # The author or authors of the referenced work
    #
    # Example: "Patricia Hartge"
    attr_accessor :creator # [USED IN SF]

    # date (http://purl.org/dc/terms/date)
    #
    # @return [String]
    # Date of publication, recommended ISO format YYYY or YYYY-MM-DD
    #
    # Example: "6/1/2009"; "2009"
    attr_accessor :date # [USED IN SF]

    # source (http://purl.org/dc/terms/source)
    #
    # @return [String]
    # If the reference is part of a larger work, this can be cited here. In case
    # of articles this is the journal, for parts of books the book itself
    #
    # Example: Nature Genetics 41, 635 (2009)
    attr_accessor :source # [USED IN SF]

    # description (http://purl.org/dc/terms/description)
    #
    # @return [String]
    # Abstracts, remarks, notes
    #
    # Example: "Five genome-wide association studies of the timing of
    # menarche and menopause have now taken us beyond the range of
    # candidate gene and linkage studies. The list of new genetic
    # associations identified for these two traits should shed light on the
    # mechanisms of ovarian aging, as well as breast cancer and other
    # diseases associated with reproductive lifespan."
    attr_accessor :description

    # subject (http://purl.org/dc/terms/subject)
    #
    # @return [String]
    # Semicolon seperated list of keywords. Can include a resource qualifier
    # that specifies the relation of this reference to the taxon, e.g
    # namePublishedIn
    #
    # Example: genomics; epidemiology
    attr_accessor :subject

    # language (http://purl.org/dc/terms/language)
    #
    # @return [String]
    # ISO 639-1 language code indicating the source language of the referent
    # publication
    #
    # Example: “en”
    attr_accessor :language

    # rights (http://purl.org/dc/terms/rights)
    #
    # @return [String]
    # Copyright information relating to the referenced publication
    #
    # Example: “Copyright © 2009 Wiley-Liss, Inc., A Wiley Company”
    attr_accessor :rights

    # taxonRemarks (http://rs.tdwg.org/dwc/terms/taxonRemarks)
    #
    # @return [String]
    # Annotation of taxon-specific information related to the referenced
    # publication.
    #
    # Example: "transferred H. nigritarsus to Acanolonia"; "Type specimen is
    # a skeleton"
    attr_accessor :taxonRemarks

    # type (http://purl.org/dc/terms/type)
    #
    # @return [String]
    # Used to assign a bibliographic reference to list of taxonomic or
    # nomenclatural categories. Best practice is to use a controlled
    # vocabulary. See an example below in data type.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/reference_type.xml
    #
    # Example: “Original publication of new combination (comb nov.)”
    attr_accessor :type # [USED IN SF]

  end
  
end