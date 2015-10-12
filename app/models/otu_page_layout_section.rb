# OtuPageLayoutSection definition...
#   @todo
#
# @!attribute otu_page_layout_id
#   @return [Integer]
#   @todo
#
# @!attribute type
#   @return [String]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute topic_id
#   @return [Integer]
#   @todo
#
# @!attribute dynamic_content_class
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class OtuPageLayoutSection < ActiveRecord::Base
  acts_as_list scope: :otu_page_layout

  include Housekeeping 
  include Shared::IsData 

  belongs_to :otu_page_layout

  validates_presence_of :type
  validates_uniqueness_of :topic_id, scope: [:otu_page_layout]

end



