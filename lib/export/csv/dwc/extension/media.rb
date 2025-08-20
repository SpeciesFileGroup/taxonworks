# CSV for for a ResourceRelationship based extension
#
module Export::CSV::Dwc::Extension::Media
  # There are 6 duplicate names:
  # * type
  # * rights
  # * source
  # * creator
  # * language
  # * format
  HEADERS = [
    'identifier',
    'dc:type',
    'dcmi:type',
    'subtypeLiteral',
    'subtype',
    'title',
    'modified',
    'MetadataDate',
    'metadataLanguageLiteral',
    'metadataLanguage',
    'providerManagedID',
    'Rating',
    'commenterLiteral',
    'commenter',
    'comments',
    'reviewerLiteral',
    'reviewer',
    'reviewerComments',
    'available',
    'hasServiceAccessPoint',
    'dc:rights',
    'dcterms:rights',
    'Owner',
    'UsageTerms',
    'WebStatement',
    'licenseLogoURL',
    'Credit',
    'attributionLogoURL',
    'attributionLinkURL',
    'fundingAttribution',
    'dc:source',
    'dcterms:source',
    'dc:creator',
    'dcterms:creator',
    'providerLiteral',
    'provider',
    'metadataCreatorLiteral',
    'metadataCreator',
    'metadataProviderLiteral',
    'metadataProvider',
    'description',
    'caption',
    'language',
    'language',
    'physicalSetting',
    'CVterm',
    'subjectCategoryVocabulary',
    'tag',
    'LocationShown',
    'WorldRegion',
    'CountryCode',
    'CountryName',
    'ProvinceState',
    'City',
    'Sublocation',
    'temporal',
    'CreateDate',
    'timeOfDay',
    'taxonCoverage',
    'scientificName',
    'identificationQualifier',
    'vernacularName',
    'nameAccordingTo',
    'scientificNameID',
    'otherScientificName',
    'identifiedBy',
    'dateIdentified',
    'taxonCount',
    'subjectPart',
    'sex',
    'lifeStage',
    'subjectOrientation',
    'preparations',
    'LocationCreated',
    'digitizationDate',
    'captureDevice',
    'resourceCreationTechnique',
    'IDofContainingCollection',
    'relatedResourceID',
    'providerID',
    'derivedFrom',
    'associatedSpecimenReference',
    'associatedObservationReference',
    'accessURI',
    'dc:format',
    'dcterms:format',
    'variantLiteral',
    'variant',
    'variantDescription',
    'furtherInformationURL',
    'licensingException',
    'serviceExpectation',
    'hashFunction',
    'hashValue',
    'PixelXDimension',
    'PixelYDimension'
  ].freeze

  def self.csv(collection_objects_scope, field_occurrences_scope)
    tbl = []
    tbl[0] = HEADERS

    collection_objects_scope.find_each do |co|
      co.darwin_core_media_extension_rows.each do |r|
        tbl << r
      end
    end

    field_occurrences_scope.find_each do |fo|
      fo.darwin_core_media_extension_rows.each do |r|
        tbl << r
      end
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end


end
