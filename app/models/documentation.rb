class Documentation < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  belongs_to :documentation_object, polymorphic: true
  belongs_to :document
end
