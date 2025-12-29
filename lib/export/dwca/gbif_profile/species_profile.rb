# Species Profile extension class
# Repository: http://rs.gbif.org/extension/gbif/1.0/speciesprofile.xml

module Export::Dwca::GbifProfile

  class SpeciesProfile
    # Field name constants
    TAXON_ID = :taxonID
    IS_MARINE = :isMarine
    IS_FRESHWATER = :isFreshwater
    IS_TERRESTRIAL = :isTerrestrial
    IS_INVASIVE = :isInvasive
    IS_HYBRID = :isHybrid
    IS_EXTINCT = :isExtinct
    LIVING_PERIOD = :livingPeriod
    AGE_IN_DAYS = :ageInDays
    SIZE_IN_MILLIMITERS = :sizeInMillimiters
    MASS_IN_GRAMS = :massInGrams
    LIFE_FORM = :lifeForm
    HABITAT = :habitat
    SEX = :sex

    # Namespace mappings
    NAMESPACES = {
      TAXON_ID => 'http://rs.tdwg.org/dwc/terms/taxonID',
      IS_MARINE => 'http://rs.gbif.org/terms/1.0/isMarine',
      IS_FRESHWATER => 'http://rs.gbif.org/terms/1.0/isFreshwater',
      IS_TERRESTRIAL => 'http://rs.gbif.org/terms/1.0/isTerrestrial',
      IS_INVASIVE => 'http://rs.gbif.org/terms/1.0/isInvasive',
      IS_HYBRID => 'http://rs.gbif.org/terms/1.0/isHybrid',
      IS_EXTINCT => 'http://rs.gbif.org/terms/1.0/isExtinct',
      LIVING_PERIOD => 'http://rs.gbif.org/terms/1.0/livingPeriod',
      AGE_IN_DAYS => 'http://rs.gbif.org/terms/1.0/ageInDays',
      SIZE_IN_MILLIMITERS => 'http://rs.gbif.org/terms/1.0/sizeInMillimeters',
      MASS_IN_GRAMS => 'http://rs.gbif.org/terms/1.0/massInGrams',
      LIFE_FORM => 'http://rs.gbif.org/terms/1.0/lifeForm',
      HABITAT => 'http://rs.tdwg.org/dwc/terms/habitat',
      SEX => 'http://rs.tdwg.org/dwc/terms/sex'
    }.freeze

    # taxonID (http://rs.tdwg.org/dwc/terms/taxonID)
    #
    # @return [String]
    # The first field in the data file should be the taxonID representing the
    # taxon in the core data file to which this record points. This
    # identifier provides the link between the core data record and the
    # extension record.
    attr_accessor TAXON_ID # [USED IN SF]

    # isMarine (http://rs.gbif.org/terms/1.0/isMarine)
    #
    # @return [String]
    # A boolean flag indicating whether the taxon is a marine organism, i.e.
    # can be found in/above sea water
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Examples: TRUE
    attr_accessor IS_MARINE

    # isFreshwater (http://rs.gbif.org/terms/1.0/isFreshwater)
    #
    # @return [String]
    # A boolean flag indicating whether the taxon occurrs in freshwater habitats,
    # i.e. can be found in/above rivers or lakes
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Examples: TRUE
    attr_accessor IS_FRESHWATER

    # isTerrestrial (http://rs.gbif.org/terms/1.0/isTerrestrial)
    #
    # @return [String]
    # A boolean flag indicating the taxon is a terrestial organism, i.e. occurrs
    # on land as opposed to the sea
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Examples: false
    attr_accessor IS_TERRESTRIAL

    # isInvasive (http://rs.gbif.org/terms/1.0/isInvasive)
    #
    # @return [String]
    # Flag indicating a species known to be invasive/alien in some are of the world.
    # Detailed native and introduced distribution areas can be published with the
    # distribution extension.
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Examples: TRUE
    attr_accessor IS_INVASIVE

    # isHybrid (http://rs.gbif.org/terms/1.0/isHybrid)
    #
    # @return [String]
    # Flag indicating a hybrid organism. This does not have to be reflected in the name,
    # but can be based on other studies like chromosome numbers etc
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Examples: TRUE
    attr_accessor IS_HYBRID

    # isExtinct (http://rs.gbif.org/terms/1.0/isExtinct)
    #
    # @return [String]
    # Flag indicating an extinct organism. Details about the timeperiod the organism has
    # lived in can be supplied in livingPeriod
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/basic/boolean.xml
    #
    # Examples: TRUE
    attr_accessor IS_EXTINCT # [USED IN SF]

    # livingPeriod (http://rs.gbif.org/terms/1.0/livingPeriod)
    #
    # @return [String]
    # The (geological) time a currently extinct organism is known to have lived. For
    # geological times of fossils ideally based on a vocabulary like
    # http://en.wikipedia.org/wiki/Geologic_column
    #
    # Examples: Cretaceous
    attr_accessor LIVING_PERIOD # [USED IN SF]

    # ageInDays (http://rs.gbif.org/terms/1.0/ageInDays)
    #
    # @return [String]
    # Maximum observed age of an organism given as number of days
    #
    # Examples: 5
    attr_accessor AGE_IN_DAYS

    # sizeInMillimiters (http://rs.gbif.org/terms/1.0/sizeInMillimeters)
    #
    # @return [String]
    # Maximum observed size of an organism in millimeter. Can be either height, length
    # or width, whichever is greater.
    #
    # Examples: 1500
    attr_accessor SIZE_IN_MILLIMITERS

    # massInGrams (http://rs.gbif.org/terms/1.0/massInGrams)
    #
    # @return [String]
    # Maximum observed weight of an organism in grams.
    #
    # Examples: 12
    attr_accessor MASS_IN_GRAMS

    # lifeForm (http://rs.gbif.org/terms/1.0/lifeForm)
    #
    # @return [String]
    # A term describing the growth/lifeform of an organism. Should be based on a
    # vocabulary like Raunkiær for plants: http://en.wikipedia.org/wiki/Raunkiær_plant
    # life-form. Recommended vocabulary: http://rs.gbif.org/vocabulary/gbif/life_form.xml
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/life_form.xml
    #
    # Examples: Phanerophyte
    attr_accessor LIFE_FORM

    # habitat (http://rs.tdwg.org/dwc/terms/habitat)
    #
    # @return [String]
    # Comma separated list of mayor habitat classification as defined by IUCN in which a
    # species is known to exist: http://www.iucnredlist.org/static/major_habitats
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/iucn/habitat.xml
    #
    # Examples: "1.1"
    attr_accessor HABITAT

    # sex (http://rs.tdwg.org/dwc/terms/sex)
    #
    # @return [String]
    # Comma separated list of known sexes to exist for this organism. Recommended
    # vocabulary is: http://rs.gbif.org/vocabulary/gbif/sex.xml
    #
    # Vocabulary: http://rs.gbif.org/vocabulary/gbif/sex.xml
    #
    # Examples: "Male,Female"
    attr_accessor SEX
  end

end