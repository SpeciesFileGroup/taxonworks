class Descriptor < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  belongs_to :project

  validates_presence_of :descriptor_id
end
