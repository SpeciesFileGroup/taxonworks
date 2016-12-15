
# A Dwc Occurrence record.  Field generated from Ruby dwc-meta, which references
# the same spec that is used in the IPT, and the Dwc Assistant.  Each record
# references a specific CollectionObject or 
#
# Important: This is a cache/index, data here are periodically (regenerated) from multiple tables in TW.  
#
#
# TODO: The basisOfRecord CVTs are not super informative.
#    We know collection object is definitely 1:1 with PreservedSpecimen, however
#    AssertedDistribution could be HumanObservation (if source is person), or ... what? if 
#    its a published record.  Seems we need a 'PublishedAssertation', just like we model the data.
#    
class DwcOccurrence < ActiveRecord::Base

#  include Shared::Housekeeping
  
#  belongs_to 

end
