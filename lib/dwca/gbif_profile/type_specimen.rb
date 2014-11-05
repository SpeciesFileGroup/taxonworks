# Types and Specimens extension class
# Repository: http://rs.gbif.org/extension/gbif/1.0/typesandspecimen.xml

module Dwca::GbifProfile

  class TypeSpecimen
    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this specimen record points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor :taxonID # [USED IN SF]

    # bibliographicCitation (http://purl.org/dc/terms/bibliographicCitation)
    #
    # @return [String]
    # A text string citating the described specimen. Often found in
    # taxonomic treatments and frequently based on institution code and
    # catalog number.
    #
    # Example: Iraq: Mosul: Jabal Khantur prope Sharanish N. Zakho, in
    # fissures rupium calc., 1200 m, Rech. 12083 (W!).
    attr_accessor :bibliographicCitation

    # occurrenceID (http://rs.tdwg.org/dwc/terms/occurrenceID)
    #
    # @return [String]
    # An identifier for the specimen, preferably a resolvable globally unique
    # identifier.
    #
    # Example: http://sweetgum.nybg.org/vh/specimen.php?irn=793312
    attr_accessor :occurrenceID

    # institutionCode (http://rs.tdwg.org/dwc/terms/institutionCode)
    #
    # @return [String]
    # The name (or acronym) in use by the institution having custody of the
    # object(s) or information referred to in the record.
    #
    # Examples: "MVZ", "FMNH", "AKN-CLO", "University of California Museum
    # of Paleontology (UCMP)"
    attr_accessor :institutionCode # [USED IN SF]

    # collectionCode (http://rs.tdwg.org/dwc/terms/collectionCode)
    #
    # @return [String]
    # The name, acronym, coden, or initialism identifying the collection or
    # data set from which the record was derived.
    #
    # Examples: "Mammals", "Hildebrandt", "eBird"
    attr_accessor :collectionCode

    # catalogNumber (http://rs.tdwg.org/dwc/terms/catalogNumber)
    #
    # @return [String]
    # An identifier (preferably unique) for the record within the data set or
    # collection.
    #
    # Examples: "2008.1334", "145732a", "145732"
    attr_accessor :catalogNumber # [USED IN SF]

    # typeStatus (http://rs.tdwg.org/dwc/terms/typeStatus)
    #
    # @return [String]
    # The type status of the specimen. Preferrably taken from a vocabulary
    # like http://rs.gbif.org/vocabulary/gbif/type_status.xml
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/type_status.xml
    #
    # Example: "holotype" "syntype" "lectotype"
    attr_accessor :typeStatus # [USED IN SF]
    
    # typeDesignationType (http://rs.gbif.org/terms/1.0/typeDesignationType)
    #
    # @return [String]
    # The reason why this specimen or name is designated as a type.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/type_designation_type.xml
    #
    # Examples: monotypy, original designation, tautonomy
    attr_accessor :typeDesignationType

    # typeDesignatedBy (http://rs.gbif.org/terms/1.0/typeDesignatedBy)
    #
    # @return [String]
    # The citation of the publication where the type designation is found
    #
    # Examples: Vachal, J. (1897) Éclaircissements sur de genre Scrapter et
    # description d’une espéce nouvelle de Dufourea. Bulletin de la Société
    # Entomologique de France, 1897, 61–64.
    attr_accessor :typeDesignatedBy # [USED IN SF]

    # scientificName (http://rs.tdwg.org/dwc/terms/scientificName)
    #
    # @return [String]
    # The scientific name as which this specimen has been identified in the
    # collection/source. Not necessarily the same as the scientific name in
    # the core file.
    #
    # Example: “Ctenomys sociabilis" "Roptrocerus typographi (Györfi, 1952)"
    attr_accessor :scientificName # [USED IN SF]

    # taxonRank (http://rs.tdwg.org/dwc/terms/taxonRank)
    #
    # @return [String]
    # The rank of the taxon bearing the scientific name
    #
    # Example: "subspecies", "varietas", "forma", "species", "genus"
    attr_accessor :taxonRank

    # identificationRemarks (http://rs.tdwg.org/dwc/terms/identificationRemarks)
    #
    # @return [String]
    # Information regarding the basis of the identification or designation (in
    # the case of type species and type genera)
    #
    # Example: by monotypy
    attr_accessor :identificationRemarks

    # locality (http://rs.tdwg.org/dwc/terms/locality)
    #
    # The location where the specimen was collected. In case of type
    # specimens the type locality.
    #
    # Example: Iraq: Mosul: Jabal Khantur prope Sharanish N. Zakho, in
    # fissures rupium calc., 1200 m
    attr_accessor :locality # [USED IN SF]

    # sex (http://rs.tdwg.org/dwc/terms/sex)
    #
    # @return [String]
    # The sex of the specimen being referenced.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/life_stage.xml
    #
    # Example: male
    attr_accessor :sex # [USED IN SF]

    # recordedBy (http://rs.tdwg.org/dwc/terms/recordedBy)
    #
    # @return [String]
    # The primary collector or observer, especially one who applies a
    # personal identifier (recordNumber), should be listed first.
    #
    # Example: KH Rechinger
    attr_accessor :recordedBy # [USED IN SF]

    # source (http://purl.org/dc/terms/source)
    #
    # @return [String]
    # Source reference for this type record. Can be proper publication
    # citation, a webpage URL, etc.
    attr_accessor :source

    # verbatimEventDate (http://rs.tdwg.org/dwc/terms/verbatimEventDate)
    #
    # @return [String]
    # The date when the specimen was collected
    #
    # Example: "spring 1910", "Marzo 2002", "1999-03-XX", "17IV1934"
    attr_accessor :verbatimEventDate # [USED IN SF]

    # verbatimLabel (http://rs.gbif.org/terms/1.0/verbatimLabel)
    #
    # @return [String]
    # The full, verbatim text from the specimen label
    attr_accessor :verbatimLabel

    # verbatimLongitude (http://rs.tdwg.org/dwc/terms/verbatimLongitude)
    #
    # @return [String]
    # The geographic longitude
    #
    # Example: 121d 10' 34 W
    attr_accessor :verbatimLongitude # [USED IN SF]

    # verbatimLatitude (http://rs.tdwg.org/dwc/terms/verbatimLatitude)
    #
    # @return [String]
    # The geographic latitude
    #
    # Example: 41 05 54.03S
    attr_accessor :verbatimLatitude # [USED IN SF]

  end
  
end

