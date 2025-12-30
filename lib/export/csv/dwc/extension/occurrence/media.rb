# CSV for for a ResourceRelationship based extension
#
module Export::CSV::Dwc::Extension::Occurrence::Media
  # There are 6 duplicate names:
  # * type
  # * rights
  # * source
  # * creator
  # * language
  # * format
  # See https://rs.gbif.org/extension/ac/audiovisual_2024_11_07.xml
  HEADERS_HASH = {
    coreid: '', # required by dwca to link to core file, not part of media
    identifier: 'http://purl.org/dc/terms/identifier',
    'dc:type': 'http://purl.org/dc/elements/1.1/type',
    #'dcmi:type': 'http://purl.org/dc/terms/type', # GBIF didn't recognize this for some reason
    #subtypeLiteral: 'http://rs.tdwg.org/ac/terms/subtypeLiteral',
    #subtype: 'http://rs.tdwg.org/ac/terms/subtype',
    #title: 'http://purl.org/dc/terms/title',
    #modified: 'http://purl.org/dc/terms/modified',
    #MetadataDate: 'http://ns.adobe.com/xap/1.0/MetadataDate',
    #metadataLanguageLiteral: 'http://rs.tdwg.org/ac/terms/metadataLanguageLiteral',
    #metadataLanguage: 'http://rs.tdwg.org/ac/terms/metadataLanguage',
    providerManagedID: 'http://rs.tdwg.org/ac/terms/providerManagedID',
    #Rating: 'http://ns.adobe.com/xap/1.0/Rating',
    #commenterLiteral: 'http://rs.tdwg.org/ac/terms/commenterLiteral',
    #commenter: 'http://rs.tdwg.org/ac/terms/commenter',
    #comments: 'http://rs.tdwg.org/ac/terms/comments',
    #reviewerLiteral: 'http://rs.tdwg.org/ac/terms/reviewerLiteral',
    #reviewer: 'http://rs.tdwg.org/ac/terms/reviewer',
    #reviewerComments: 'http://rs.tdwg.org/ac/terms/reviewerComments',
    #available: 'http://purl.org/dc/terms/available',
    #hasServiceAccessPoint: 'http://rs.tdwg.org/ac/terms/hasServiceAccessPoint',
    'dc:rights': 'http://purl.org/dc/elements/1.1/rights',
    'dcterms:rights': 'http://purl.org/dc/terms/rights',
    Owner: 'http://ns.adobe.com/xap/1.0/rights/Owner',
    #UsageTerms: 'http://ns.adobe.com/xap/1.0/rights/UsageTerms',
    #WebStatement: 'http://ns.adobe.com/xap/1.0/rights/WebStatement',
    #licenseLogoURL: 'http://rs.tdwg.org/ac/terms/licenseLogoURL',
    Credit: 'http://ns.adobe.com/photoshop/1.0/Credit',
    #attributionLogoURL: 'http://rs.tdwg.org/ac/terms/attributionLogoURL',
    #attributionLinkURL: 'http://rs.tdwg.org/ac/terms/attributionLinkURL',
    #fundingAttribution: 'http://rs.tdwg.org/ac/terms/fundingAttribution',
    #'dc:source': 'http://purl.org/dc/elements/1.1/source',
    #'dcterms:source': 'http://purl.org/dc/terms/source',
    'dc:creator': 'http://purl.org/dc/elements/1.1/creator',
    'dcterms:creator': 'http://purl.org/dc/terms/creator',
    #providerLiteral: 'http://rs.tdwg.org/ac/terms/providerLiteral',
    #provider: 'http://rs.tdwg.org/ac/terms/provider',
    #metadataCreatorLiteral: 'http://rs.tdwg.org/ac/terms/metadataCreatorLiteral',
    #metadataCreator: 'http://rs.tdwg.org/ac/terms/metadataCreator',
    #metadataProviderLiteral: 'http://rs.tdwg.org/ac/terms/metadataProviderLiteral',
    #metadataProvider: 'http://rs.tdwg.org/ac/terms/metadataProvider',
    description: 'http://purl.org/dc/terms/description',
    caption: 'http://rs.tdwg.org/ac/terms/caption',
    #'dc:language': 'http://purl.org/dc/elements/1.1/language',
    #'dcterms:language': 'http://purl.org/dc/terms/language',
    #physicalSetting: 'http://rs.tdwg.org/ac/terms/physicalSetting',
    #CVterm: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/CVterm',
    #subjectCategoryVocabulary: 'http://rs.tdwg.org/ac/terms/subjectCategoryVocabulary',
    #tag: 'http://rs.tdwg.org/ac/terms/tag',
    #LocationShown: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/LocationShown',
    #WorldRegion: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/WorldRegion',
    #CountryCode: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/CountryCode',
    #CountryName: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/CountryName',
    #ProvinceState: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/ProvinceState',
    #City: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/City',
    #Sublocation: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/Sublocation',
    #temporal: 'http://purl.org/dc/terms/temporal',
    #CreateDate: 'http://ns.adobe.com/xap/1.0/CreateDate',
    #timeOfDay: 'http://rs.tdwg.org/ac/terms/timeOfDay',
    #taxonCoverage: 'http://rs.tdwg.org/ac/terms/taxonCoverage',
    #scientificName: 'http://rs.tdwg.org/dwc/terms/scientificName',
    #identificationQualifier: 'http://rs.tdwg.org/dwc/terms/identificationQualifier',
    #vernacularName: 'http://rs.tdwg.org/dwc/terms/vernacularName',
    #nameAccordingTo: 'http://rs.tdwg.org/dwc/terms/nameAccordingTo',
    #scientificNameID: 'http://rs.tdwg.org/dwc/terms/scientificNameID',
    #otherScientificName: 'http://rs.tdwg.org/ac/terms/otherScientificName',
    #identifiedBy: 'http://rs.tdwg.org/dwc/terms/identifiedBy',
    #dateIdentified: 'http://rs.tdwg.org/dwc/terms/dateIdentified',
    #taxonCount: 'http://rs.tdwg.org/ac/terms/taxonCount',
    #subjectPart: 'http://rs.tdwg.org/ac/terms/subjectPart',
    #sex: 'http://rs.tdwg.org/dwc/terms/sex',
    #lifeStage: 'http://rs.tdwg.org/dwc/terms/lifeStage',
    #subjectOrientation: 'http://rs.tdwg.org/ac/terms/subjectOrientation',
    #preparations: 'http://rs.tdwg.org/dwc/terms/preparations',
    #LocationCreated: 'http://iptc.org/std/Iptc4xmpExt/2008-02-29/LocationCreated',
    #digitizationDate: 'http://rs.tdwg.org/ac/terms/digitizationDate',
    #captureDevice: 'http://rs.tdwg.org/ac/terms/captureDevice',
    #resourceCreationTechnique: 'http://rs.tdwg.org/ac/terms/resourceCreationTechnique',
    #IDofContainingCollection: 'http://rs.tdwg.org/ac/terms/IDofContainingCollection',
    #relatedResourceID: 'http://rs.tdwg.org/ac/terms/relatedResourceID',
    #providerID: 'http://rs.tdwg.org/ac/terms/providerID',
    #derivedFrom: 'http://rs.tdwg.org/ac/terms/derivedFrom',
    associatedSpecimenReference: 'http://rs.tdwg.org/ac/terms/associatedSpecimenReference',
    #associatedObservationReference: 'http://rs.tdwg.org/ac/terms/associatedObservationReference',
    accessURI: 'http://rs.tdwg.org/ac/terms/accessURI',
    'dc:format': 'http://purl.org/dc/elements/1.1/format',
    #'dcterms:format': 'http://purl.org/dc/terms/format',
    #variantLiteral: 'http://rs.tdwg.org/ac/terms/variantLiteral',
    #variant: 'http://rs.tdwg.org/ac/terms/variant',
    #variantDescription: 'http://rs.tdwg.org/ac/terms/variantDescription',
    furtherInformationURL: 'http://rs.tdwg.org/ac/terms/furtherInformationURL',
    #licensingException: 'http://rs.tdwg.org/ac/terms/licensingException',
    #serviceExpectation: 'http://rs.tdwg.org/ac/terms/serviceExpectation',
    #hashFunction: 'http://rs.tdwg.org/ac/terms/hashFunction',
    #hashValue: 'http://rs.tdwg.org/ac/terms/hashValue',
    PixelXDimension: 'http://ns.adobe.com/exif/1.0/PixelXDimension',
    PixelYDimension: 'http://ns.adobe.com/exif/1.0/PixelYDimension',
  }.freeze

  HEADERS = HEADERS_HASH.keys.freeze

  HEADERS_INDEX = HEADERS.each_with_index.to_h.freeze

  HEADERS_NAMESPACES = HEADERS_HASH.values.freeze

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
