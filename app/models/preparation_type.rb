class PreparationType < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 
  include Shared::SharedAcrossProjects
 
  has_paper_trail

  has_many :collection_objects, dependent: :restrict_with_error
  validates_presence_of :name, :definition

end
