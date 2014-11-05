class LoanItem < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  belongs_to :loan
  belongs_to :collection_object
end
