class CollectionObject < ActiveRecord::Base

  include Shared::Identifiable
  include Shared::Containable

  belongs_to :preparation_type

end
