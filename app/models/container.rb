class Container < ActiveRecord::Base

  include Shared::Identifiable
  include Shared::Containable

  belongs_to :container_type_id
  has_many :specimens

end

