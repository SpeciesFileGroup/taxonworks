# Vernacular Names extension class
# Repository: http://rs.gbif.org/extension/gbif/1.0/vernacular.xml

module Export::Dwca::GbifProfile

  class VernacularName
    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this vernacular name points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor :taxonID # [USED IN SF]

    # vernacularName (http://rs.tdwg.org/dwc/terms/vernacularName)
    #
    # @return [String]
    # A common or vernacular name.
    #
    # Example: Andean Condor", "Condor Andino", "American Eagle",
    # "Gönsegeier"
    attr_accessor :vernacularName # [USED IN SF]

    # source (http://purl.org/dc/terms/source)
    #
    # @return [String]
    # Bibliographic citation referencing a source where the vernacular name
    # refers to the cited species.
    #
    # Example: "Peterson Field Guide to the Eastern Seashore, Houghton
    # Mifflin Co, 1961, p131"
    attr_accessor :source

    # language (http://purl.org/dc/terms/language)
    #
    # @return [String]
    # ISO 639-1 language code used for the vernacular name value.
    #
    # Example: “ES”, “Spanish”, “Español”
    attr_accessor :language # [USED IN SF]

    # temporal (http://purl.org/dc/terms/temporal)
    #
    # @return [String]
    # temporal context when name is/was used
    #
    # Example: “19th Century”; 1950
    attr_accessor :temporal

    # locationID (http://rs.tdwg.org/dwc/terms/locationID)
    #
    # @return [String]
    # An identifier for the set of location information (data associated with
    # dcterms:Location). May be a global unique identifier or an identifier
    # specific to the data set.
    attr_accessor :locationID

    # locality (http://rs.tdwg.org/dwc/terms/locality)
    #
    # @return [String]
    # The specific description of the area from which the vernacular name
    # usage originates. Vernacular names may have very specific regional
    # contexts. A name used for a species in one area may refer to a
    # different species in another.
    #
    # Example: "Southeastern coastal New England from Buzzards Bay
    # through Rhode Island"
    attr_accessor :locality

    # countryCode (http://rs.tdwg.org/dwc/terms/countryCode)
    #
    # @return [String]
    # The standard code for the country in which the vernacular name is
    # used. Recommended best practice is to use the ISO 3166-1-alpha-2
    # country codes available as a vocabulary at
    # http://rs.gbif.org/vocabulary/iso/3166-1_alpha2.xml. For multiple
    # countries separate values with a comma ","
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/iso/3166-1_alpha2.xml
    #
    # Example: "AR" for Argentina, "SV" for El Salvador. "AR,CR,SV" for
    # Argentina, Costa Rica, and El Salvador combined.
    attr_accessor :countryCode

    # sex (http://rs.tdwg.org/dwc/terms/sex)
    #
    # @return [String]
    # The sex (gender) of the taxon for which the vernacular name applies
    # when the vernacular name is limited to a specific gender of a species.
    # If not limited sex should be empty. For example the vernacular name
    # "Buck" applies to the "Male" gender of the species, Odocoileus
    # virginianus.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/sex.xml
    #
    # Example: “male”
    attr_accessor :sex

    # lifeStage (http://rs.tdwg.org/dwc/terms/lifeStage)
    #
    # @return [String]
    # The age class or life stage of the species for which the vernacular
    # name applies. Best practice is to utilise a controlled list of terms for
    # this value.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/life_stage.xml
    #
    # Example: ‘juvenile" is the life stage of the fish Pomatomus saltatrix
    # for which the name "snapper blue" refers.’
    attr_accessor :lifeStage

    # isPlural (http://rs.gbif.org/terms/1.0/isPlural)
    #
    # @return [String]
    # This value is true if the vernacular name it qualifies refers to a plural
    # form of the name.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Example: The term "Schoolies" is the plural form of a name used along
    # the coastal Northeastern U.S. for groups of juvenile fish of the species,
    # Morone saxatilis.
    attr_accessor :isPlural

    # isPreferredName (http://rs.gbif.org/terms/1.0/isPreferredName)
    #
    # @return [String]
    # This term is true if the source citing the use of this vernacular name
    # indicates the usage has some preference or specific standing over
    # other possible vernacular names used for the species.
    # Some organisations have attempted to assign specific and unique
    # vernacular names for particular taxon groups in a systematic attempt
    # to bring order and consistency to the use of these names. For example,
    # the American Ornithological Union assigns the name "Pearl Kite" for the
    # taxon, Gampsonyx swainsonii. The value of isPreferredName for this
    # record would be true.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Example: “True” “False”
    attr_accessor :isPreferredName

    # organismPart (http://rs.gbif.org/terms/1.0/organismPart)
    #
    # @return [String]
    # The part of the organism to which the vernacular name refers. Best
    # practice is to utilise a controlled vocabulary for this term although it is
    # likely that multiple controlled lists for different organism groups may
    # be the best implementation for this term.
    # The spice "Mace", is derived from the "aril" of the plant Myristica
    # fragrans while the spice "nutmeg" is derived from the "seed." "Seed"
    # and "Aril" represent two different values for organismPart.
    attr_accessor :organismPart

    # taxonRemarks (http://rs.tdwg.org/dwc/terms/taxonRemarks)
    #
    # @return [String]
    # A description of any context that qualify the specific usage of the
    # vernacular name.
    #
    # Example: “This name applies only when the fruit has been blessed by
    # a tribal shaman”
    attr_accessor :taxonRemarks

  end
  
end