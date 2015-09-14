# OtuPageLayout definition...
#   @todo
#
# @!attribute name
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class OtuPageLayout < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  has_many :otu_page_layout_sections, inverse_of: :otu_page_layout, dependent: :destroy
  has_many :topics, through: :otu_page_layout_sections 

  validates_presence_of :name
end
