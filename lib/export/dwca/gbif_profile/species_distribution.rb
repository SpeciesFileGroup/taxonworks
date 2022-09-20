# Species Distribution extension class
# Repository: http://rs.gbif.org/extension/gbif/1.0/distribution.xml

module Export::Dwca::GbifProfile

  class SpeciesDistribution
    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this distribution record points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor :taxonID # [USED IN SF]

    # locality (http://rs.tdwg.org/dwc/terms/locality)
    #
    # @return [String]
    # The verbatim name of the area this distributon record is about.
    #
    # Example: “Patagonia”
    attr_accessor :locality # [USED IN SF]

    # locationID (http://rs.tdwg.org/dwc/terms/locationID)
    #
    # @return [String]
    # A code for the named area this distributon record is about. See
    # http://en.wikipedia.org/wiki/ISO_3166-2 for state codes within a
    # country, otherwise use a prefix for each code to indicate the source of
    # the code. See http://rs.gbif.org/areas/ for GBIF recommended area
    # vocabularies
    #
    # Example: “TDWG:AGS-TF; ISO3166:AR; WOEID:564721”
    attr_accessor :locationID # [USED IN SF]

    # countryCode (http://rs.tdwg.org/dwc/terms/countryCode)
    #
    # @return [String]
    # ISO3166 alpha 2 (3 is permissable) country codes the area belongs to or as
    # an alternative for a lcoationID if the area is a country. For multiple
    # countries separate values with a comma "," Use country name if
    # necessary.
    #
    # Example: "AR" "US;CA;MX"
    attr_accessor :countryCode

    # lifeStage (http://rs.tdwg.org/dwc/terms/lifeStage)
    #
    # @return [String]
    # The distribution information pertains solely to a specific life stage of the
    # taxon. See the Life Stage vocabulary at
    # http://rs.gbif.org/vocabulary/gbif/life_stage.xml for recommended
    # values.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/life_stage.xml 
    #
    # Example: “adult”
    attr_accessor :lifeStage

    # occurrenceStatus (http://rs.tdwg.org/dwc/terms/occurrenceStatus)
    #
    # @return [String]
    # Term describing the status of the organism in the given area based on
    # how frequent the species occurs. See the Occurrence status vocabulary
    # at http://rs.gbif.org/vocabulary/gbif/occurrence_status.xml for
    # recommended values.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/occurrence_status.xml
    #
    # Example: “Absent” “present”
    attr_accessor :occurrenceStatus

    # threatStatus (http://rs.gbif.org/terms/1.0/threatStatus)
    #
    # @return [String]
    # Threat status of a species as defined by IUCN:
    # http://www.iucnredlist.org/static/categories_criteria_3_1 - categories
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/iucn/threat_status.xml
    #
    # Example: "EX" "EW" "CR"
    attr_accessor :threatStatus

    # establishmentMeans (http://rs.tdwg.org/dwc/terms/establishmentMeans)
    #
    # @return [String]
    # Term describing whether the organism occurs natively, is introduced or
    # cultivated.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/establishment_means.xml
    #
    # Example: “introduced”
    attr_accessor :establishmentMeans

    # appendixCITES (http://rs.gbif.org/terms/1.0/appendixCITES)
    #
    # @return [String]
    # The CITES (Convention on International Trade in Endangered Species of
    # Wild Fauna and Flora) Appendix number the taxa is listed. It is possible to
    # have different appendix numbers for different areas, but "global" as an
    # area is also valid if its the same worldwide
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/un/cites_appendix.xml
    #
    # Example: “II”
    attr_accessor :appendixCITES

    # eventDate (http://rs.tdwg.org/dwc/terms/eventDate)
    #
    # @return [String]
    # Relevant temporal context for the distribution record. Preferably given as
    # a year range or single year on which the distribution record is valid. For
    # the same area and taxon there could therefore be several records with
    # different temporal context, e.g. in 5 year intervals for invasive species.
    #
    # Example: "1930"; "1939-1945"
    attr_accessor :eventDate

    # startDayOfYear (http://rs.tdwg.org/dwc/terms/startDayOfYear)
    #
    # @return [String]
    # Seasonal temporal subcontext within the eventDate context. Useful for
    # migratory species. The earliest ordinal day of the year on which the
    # distribution record is valid. Numbering starts with 1 for January 1 and
    # ends with 365 (or 366 if it is a leap year) for December 31.
    #
    # Example: "90"
    attr_accessor :startDayOfYear

    # endDayOfYear (http://rs.tdwg.org/dwc/terms/endDayOfYear)
    #
    # @return [String]
    # Seasonal temporal subcontext within the eventDate context. The latest
    # ordinal day of the year on which the distribution record is valid
    #
    # Example: "120"
    attr_accessor :endDayOfYear

    # source (http://purl.org/dc/terms/source)
    #
    # @return [String]
    # Source reference for this distribution record. Can be proper publication
    # citation, a webpage URL, etc.
    #
    # Example: "Euro+Med Plantbase - the information resource for 
    # Euro-Mediterranean plant diversity (2006-). Published on the Internet
    # http://ww2.bgbm.org/EuroPlusMed/ July, 2009"
    attr_accessor :source

    # occurrenceRemarks (http://rs.tdwg.org/dwc/terms/occurrenceRemarks)
    #
    # @return [String]
    # Comments or notes about the distribution
    #
    # Example: "Excluded because of misidentification"
    attr_accessor :occurrenceRemarks
  end
  
end