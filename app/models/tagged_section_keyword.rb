class TaggedSectionKeyword < ActiveRecord::Base
  include Housekeeping

  acts_as_list

  belongs_to :otu_page_layout_section
  belongs_to :keyword

  validates :keyword, presence: true
  validates :otu_page_layout_section, presence: true
  
end
