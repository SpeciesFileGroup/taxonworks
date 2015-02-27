class LoanItem < ActiveRecord::Base
  acts_as_list scope: :loan

  include Housekeeping
  include Shared::IsData 

  belongs_to :loan
  belongs_to :collection_object
end
