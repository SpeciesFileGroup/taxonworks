class CollectionObject < ActiveRecord::Base

  include Shared::Identifiable
  include Shared::Containable
  include Shared::Citable

  belongs_to :preparation_type

end
