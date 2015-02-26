class OtuPageLayoutSection < ActiveRecord::Base
  acts_as_list scope: :otu_page_layout

  include Housekeeping 
  include Shared::IsData 

  belongs_to :otu_page_layout
  belongs_to :topic
  validates_presence_of :type
end
