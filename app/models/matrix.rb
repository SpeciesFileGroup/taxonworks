class Matrix < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable              
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable
<<<<<<< 78e56ca3c2632af3840134e92a40c450e3f7cb5d
  include Shared::DataAttributes

  validates_presence_of :name

  has_many :matrix_column_items, dependent: :destroy
=======

  belongs_to :project

  validates_presence_of :name
>>>>>>> Scaffolded matrix model, basics integrated in TW interface. Tests updated.

end
