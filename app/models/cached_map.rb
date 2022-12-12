
# Radial navigate from CollectingEvent to 
#
# TODO:
# * OTU change
# * AssertedDistribution change
# * Georefrence change
# * CollectingEvent change


# Summarize data from Georeferences and AssertedDistributions for mapping/visualization purposes.
# All data are `cached` sensu TaxonWorks, i.e. derived from underlying data elsewher.

# @!attribute otu_id
#   @return [Otu#id],
#     the id of OTU, required 
#
# @!attribute geographic_item_id
#   @return [GeographicItem#id],
#     the id of GeographicItem, required
#
# @!attribute type 
#   @return [String],
#     Rails STI 
#
# @!attribute reference_count
#   @return [Integer]
#      the number of Georeferences + AssertedDistributions that 
#   reference this OTU/shape combination. . . . . 
#
# @!attribute is_absent 
#   @return [Boolean, nil]
#     if True then the corresponding AssertedDistributions have is_absent true 
#
# @!attribute is_absent 
#   @return [Boolean, nil]
#     if True then the corresponding AssertedDistributions have is_absent true 
#
# @!attribute level0_geographic_name 
#   @return [String, nil]
#      the level 0 name  
#
# @!attribute level1_geographic_name 
#   @return [String, nil]
#      the level 1 name  
#
# @!attribute level2_geographic_name 
#   @return [String, nil]
#      the level 2 name. !! Not presently used. !!
#
class CachedMap < ApplicationRecord
  include Housekeeping::Projects
  include Housekeeping::Timestamps

  include Shared::IsData

  belongs_to :otu
  belongs_to :geographic_item

  validates_presence_of :otu, :geogrpahic_item

end

https://zoobank.org:act:9C82ADD4-3277- 489C-8201-0B5DF42FA0D1
