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
class OtuPageLayoutSection < ApplicationRecord
  acts_as_list scope: [:otu_page_layout, :project_id]

  include Housekeeping
  include Shared::IsData

  belongs_to :otu_page_layout
  belongs_to :topic, inverse_of: :otu_page_layout_sections

  validates_presence_of :type
  validates_uniqueness_of :topic_id, scope: [:otu_page_layout_id]


#  def self.title
#    'empty' # nil
#  end
#
#  def title
#    self.class.title
#  end
#
#  def self.description
#    nil
#  end
#
#  def self.preview_image
#   'sections/xxx.jpg'
#  end
#
#  def content
#    {partial: '',
#     locals: {local1: 'value'}
#    }
#  end


end



