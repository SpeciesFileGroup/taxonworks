# Via dwc-meta http://github.com/SpeciesFileGroup/dwc-meta
# Source http://rs.gbif.org/core/dwc_occurrence_2015-07-02.xml
# On 2016-12-14 16:17:27 -0600
#
# You will need to add this line to your model:
#    self.inheritance_column = nil
class CreateDwcOccurrence < ActiveRecord::Migration
  def change
    create_table :dwc_occurrences do |t|
      t.string :acceptedNameUsage
      t.string :acceptedNameUsage
      t.string :acceptedNameUsageID
      t.string :accessRights
      t.string :associatedMedia
      t.string :associatedOccurrences
      t.string :associatedOrganisms
      t.string :associatedReferences
      t.string :associatedSequences
      t.string :associatedTaxa
      t.string :basisOfRecord, nil: false
      t.string :bed
      t.string :behavior
      t.string :bibliographicCitation
      t.string :catalogNumber
      t.string :dwcClass
      t.string :collectionCode
      t.string :collectionID
      t.string :continent
      t.string :coordinatePrecision
      t.string :coordinateUncertaintyInMeters
      t.string :country
      t.string :countryCode
      t.string :county
      t.string :dataGeneralizations
      t.string :datasetID
      t.string :datasetName
      t.string :dateIdentified
      t.string :day
      t.string :decimalLatitude
      t.string :decimalLongitude
      t.string :disposition
      t.string :dynamicProperties
      t.string :earliestAgeOrLowestStage
      t.string :earliestEonOrLowestEonothem
      t.string :earliestEpochOrLowestSeries
      t.string :earliestEraOrLowestErathem
      t.string :earliestPeriodOrLowestSystem
      t.string :endDayOfYear
      t.string :establishmentMeans
      t.string :eventDate
      t.string :eventID
      t.string :eventRemarks
      t.string :eventTime
      t.string :family
      t.string :fieldNotes
      t.string :fieldNumber
      t.string :footprintSRS
      t.string :footprintSpatialFit
      t.string :footprintWKT
      t.string :formation
      t.string :genus
      t.string :geodeticDatum
      t.string :geologicalContextID
      t.string :georeferenceProtocol
      t.string :georeferenceRemarks
      t.string :georeferenceSources
      t.string :georeferenceVerificationStatus
      t.string :georeferencedBy
      t.string :georeferencedDate
      t.string :group
      t.string :habitat
      t.string :higherClassification
      t.string :higherGeography
      t.string :higherGeographyID
      t.string :highestBiostratigraphicZone
      t.string :identificationID
      t.string :identificationQualifier
      t.string :identificationReferences
      t.string :identificationRemarks
      t.string :identificationVerificationStatus
      t.string :identifiedBy
      t.string :individualCount
      t.string :informationWithheld
      t.string :infraspecificEpithet
      t.string :institutionCode
      t.string :institutionID
      t.string :island
      t.string :islandGroup
      t.string :kingdom
      t.string :language
      t.string :latestAgeOrHighestStage
      t.string :latestEonOrHighestEonothem
      t.string :latestEpochOrHighestSeries
      t.string :latestEraOrHighestErathem
      t.string :latestPeriodOrHighestSystem
      t.string :license
      t.string :lifeStage
      t.string :lithostratigraphicTerms
      t.string :locality
      t.string :locationAccordingTo
      t.string :locationID
      t.string :locationRemarks
      t.string :lowestBiostratigraphicZone
      t.string :materialSampleID
      t.string :maximumDepthInMeters
      t.string :maximumDistanceAboveSurfaceInMeters
      t.string :maximumElevationInMeters
      t.string :member
      t.string :minimumDepthInMeters
      t.string :minimumDistanceAboveSurfaceInMeters
      t.string :minimumElevationInMeters
      t.string :modified
      t.string :month
      t.string :municipality
      t.string :nameAccordingTo
      t.string :nameAccordingToID
      t.string :namePublishedIn
      t.string :namePublishedInID
      t.string :namePublishedInYear
      t.string :nomenclaturalCode
      t.string :nomenclaturalStatus
      t.string :occurrenceID
      t.string :occurrenceRemarks
      t.string :occurrenceStatus
      t.string :order
      t.string :organismID
      t.string :organismName
      t.string :organismQuantity
      t.string :organismQuantityType
      t.string :organismRemarks
      t.string :organismScope
      t.string :originalNameUsage
      t.string :originalNameUsageID
      t.string :otherCatalogNumbers
      t.string :ownerInstitutionCode
      t.string :parentEventID
      t.string :parentNameUsage
      t.string :parentNameUsageID
      t.string :phylum
      t.string :pointRadiusSpatialFit
      t.string :preparations
      t.string :previousIdentifications
      t.string :recordNumber
      t.string :recordedBy
      t.string :references
      t.string :reproductiveCondition
      t.string :rightsHolder
      t.string :sampleSizeUnit
      t.string :sampleSizeValue
      t.string :samplingEffort
      t.string :samplingProtocol
      t.string :scientificName
      t.string :scientificNameAuthorship
      t.string :scientificNameID
      t.string :sex
      t.string :specificEpithet
      t.string :startDayOfYear
      t.string :stateProvince
      t.string :subgenus
      t.string :taxonConceptID
      t.string :taxonID
      t.string :taxonRank
      t.string :taxonRemarks
      t.string :taxonomicStatus
      t.string :type
      t.string :typeStatus
      t.string :verbatimCoordinateSystem
      t.string :verbatimCoordinates
      t.string :verbatimDepth
      t.string :verbatimElevation
      t.string :verbatimEventDate
      t.string :verbatimLatitude
      t.string :verbatimLocality
      t.string :verbatimLongitude
      t.string :verbatimSRS
      t.string :verbatimTaxonRank
      t.string :vernacularName
      t.string :waterBody
      t.string :year
      t.references :dwc_occurrence_object, polymorphic: true
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true
      t.timestamps
    end

    add_foreign_key :dwc_occurrences, :users, column: :created_by_id
    add_foreign_key :dwc_occurrences, :users, column: :updated_by_id
  end
end
