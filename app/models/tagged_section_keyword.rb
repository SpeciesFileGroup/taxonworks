# TaggedSectionKeyword definition...
# @todo
#
# @!attribute otu_page_layout_section_id
#   @return [Integer]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute keyword_id
#   @return [Integer]
#   @todo
#
class TaggedSectionKeyword < ApplicationRecord
  include Housekeeping
  include Shared::IsData


  acts_as_list scope: [:otu_page_layout_section, :project_id]

  belongs_to :otu_page_layout_section
  belongs_to :keyword

  validates :keyword, presence: true
  validates :otu_page_layout_section, presence: true

end
