class OtuPageLayoutSection < ActiveRecord::Base
  include Housekeeping 
  include Shared::IsData 

  belongs_to :otu_page_layout
  belongs_to :topic

end
