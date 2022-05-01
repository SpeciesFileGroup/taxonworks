# Intent as a dictionary that ultimately lets us extend 
# assertions beyond DWC to OWL/OBO URIs referenced in TaxonWorks Predicate (controlled vocabulary terms)

DWC_ATTRIBUTE_URIS =  {
  sex: [
    'http://rs.tdwg.org/dwc/terms/sex'
  ],

  lifeStage: [
    'http://rs.tdwg.org/dwc/terms/lifeStage'
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
  ] 

}

# Reference the same URI throughout
DWC_FOSSIL_URI = 'http://rs.tdwg.org/dwc/terms/FossilSpecimen'

