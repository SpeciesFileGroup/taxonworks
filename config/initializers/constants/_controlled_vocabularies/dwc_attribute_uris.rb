# Intent as a dictionary that ultimately lets us extend
# assertions beyond DWC to OWL/OBO URIs referenced in TaxonWorks Predicate (controlled vocabulary terms)

DWC_ATTRIBUTE_URIS = {
  sex: [
    'http://rs.tdwg.org/dwc/terms/sex'
  ],

  lifeStage: [
    'http://rs.tdwg.org/dwc/terms/lifeStage'
  ],

  caste: [
    'http://rs.tdwg.org/dwc/terms/caste'
  ],

  waterBody: [
    'http://rs.tdwg.org/dwc/terms/waterBody'
  ],

  minimumDepthInMeters: [
    'http://rs.tdwg.org/dwc/terms/minimumDepthInMeters'
  ],

  maximumDepthInMeters: [
    'http://rs.tdwg.org/dwc/terms/maximumDepthInMeters'
  ],

  verbatimDepth: [
    'http://rs.tdwg.org/dwc/terms/verbatimDepth'
  ] ,

  associatedTaxa: [
    'http://rs.tdwg.org/dwc/terms/associatedTaxa'
  ]
}.freeze

# Reference the same URI throughout
DWC_FOSSIL_URI = 'http://rs.tdwg.org/dwc/terms/FossilSpecimen'.freeze

# Maps iNaturalist annotation controlled_attribute labels to DwC URIs.
# iNat controlled terms carry no URIs of their own, so TW owns the mapping.
# Only attributes with a direct DwC equivalent are included.
INAT_ANNOTATION_LABEL_TO_DWC_URI = {
  'Sex' => DWC_ATTRIBUTE_URIS[:sex].first,
  'Life Stage' => DWC_ATTRIBUTE_URIS[:lifeStage].first,
}.freeze

