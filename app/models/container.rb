class Container < ActiveRecord::Base
  acts_as_nested_set

  include Shared::Identifiable
  include Shared::Containable

  belongs_to :container_type_id
  has_many :specimens
end

