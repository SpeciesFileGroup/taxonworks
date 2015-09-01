class OtuPageLayoutSection < ActiveRecord::Base
  acts_as_list scope: :otu_page_layout

  include Housekeeping 
  include Shared::IsData 

  belongs_to :otu_page_layout

  validates_presence_of :type
  validates_uniqueness_of :topic_id, scope: [:otu_page_layout]

end



