class OtuPageLayout < ActiveRecord::Base
  include Housekeeping
 
  has_many :otu_page_layout_sections, inverse_of: :otu_page_layout
  has_many :topics, through: :otu_page_layout_sections 

  validates_presence_of :name
  
end
