class CharacterState < ActiveRecord::Base

  include Housekeeping
  include Shared::Depictions
  include Shared::IsData
  include Shared::Notable
  include Shared::Identifiable
  include Shared::Taggable
  include Shared::Confidence
  include Shared::Documentation
  include Shared::Citable

  acts_as_list scope: [:descriptor_id]

  belongs_to :descriptor

  validates :descriptor, presence: true
  validates_presence_of :name
  validates_presence_of :label
  validates_uniqueness_of :name, scope: [:descriptor_id]
  validates_uniqueness_of :label, scope: [:descriptor_id]

  validate :descriptor_kind

  protected

  def descriptor_kind
    errors.add(:descriptor, 'must be Descriptor::Qualitative') if descriptor && descriptor.type != 'Descriptor::Qualitative'
  end
  
end
