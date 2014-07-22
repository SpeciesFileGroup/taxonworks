class OtuPageLayoutSection < ActiveRecord::Base
  include Housekeeping 
  belongs_to :otu_page_layout
  belongs_to :topic

  validates_inclusion_of :type, in: %w{OtuPageLayoutSection::StandardSection OtuPageLayoutSection::DynamicSection OtuPageLayoutSection::TaggedSection} 
end
