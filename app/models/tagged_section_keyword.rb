class TaggedSectionKeyword < ActiveRecord::Base
  belongs_to :otu_page_layout_section
  belongs_to :project
end
