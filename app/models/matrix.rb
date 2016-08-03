class Matrix < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable              
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable

  belongs_to :project

  validates_presence_of :name

end
