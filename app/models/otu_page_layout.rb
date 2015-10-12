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

  has_many :otu_page_layout_sections, -> { order(:position) }, inverse_of: :otu_page_layout, dependent: :destroy
  has_many :standard_sections, -> { order(:position) }, class_name: 'OtuPageLayoutSection::StandardSection', inverse_of: :otu_page_layout, dependent: :destroy

  has_many :topics, through: :standard_sections

  accepts_nested_attributes_for :otu_page_layout_sections, allow_destroy: true
  accepts_nested_attributes_for :standard_sections, allow_destroy: true

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:project_id]
end
