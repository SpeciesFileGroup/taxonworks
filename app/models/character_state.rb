# A qualitative state, as traditionally used in Phylogenetic characters and descriptive taxonomy.
#
#  @!attribute name
#   @return [String]
#      the full name of the character state, like "blue"
#
#  @!attribute label
#   @return [String]
#      the label presented in the matrix, like "0", or "1"
#
class CharacterState < ApplicationRecord

  include Housekeeping
  include Shared::Depictions
  include Shared::IsData
  include Shared::Notes
  include Shared::Identifiers
  include Shared::Tags
  include Shared::Confidences
  include Shared::Documentation
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::AlternateValues
  include SoftValidation

  acts_as_list scope: [:descriptor_id]

  ALTERNATE_VALUES_FOR = [:name, :label].freeze

  belongs_to :descriptor, inverse_of: :character_states, class_name: 'Descriptor::Qualitative'
  has_many :observations, inverse_of: :character_state

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
