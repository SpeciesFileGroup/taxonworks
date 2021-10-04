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
  include Shared::Notes
  include Shared::Identifiers
  include Shared::Tags
  include Shared::Confidences
  include Shared::Documentation
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::AlternateValues
  include Shared::IsData

  include SoftValidation

  acts_as_list scope: [:descriptor_id, :project_id]

  ALTERNATE_VALUES_FOR = [:name, :label, :description_name, :key_name].freeze

  belongs_to :descriptor, inverse_of: :character_states, class_name: 'Descriptor::Qualitative'
  has_many :observations, inverse_of: :character_state, dependent: :restrict_with_error

  validates :descriptor, presence: true
  validates_presence_of :name
  validates_presence_of :label
  validates_uniqueness_of :name, scope: [:descriptor_id]
  validates_uniqueness_of :label, scope: [:descriptor_id]

  validate :descriptor_kind

  ## retrunrs string, name of the character_state in a particular language
  # target: :key, :description, nil
  def target_name(target, language_id)
    n = self.name
    a = nil
    case target
    when :key
      n = self.key_name.nil? ? n : self.key_name
    when :description
      n = self.description_name.nil? ? n : self.description_name
    end
    unless language_id.nil?
      case target
      when :key
        a = AlternateValue::Translation.
          where(alternate_value_object: self, language_id: language_id).
          where("(alternate_values.alternate_value_object_attribute = 'key_name' OR alternate_values.alternate_value_object_attribute = 'name')").
          order(:alternate_value_object_attribute).pluck(:value).first
      when :description
        a = AlternateValue::Translation.
          where(alternate_value_object: self, language_id: language_id).
          where("(alternate_values.alternate_value_object_attribute = 'description_name' OR alternate_values.alternate_value_object_attribute = 'name')").
          order(:alternate_value_object_attribute).pluck(:value).first
      end
    end
    return a.nil? ? n : a
  end

  protected

  def descriptor_kind
    errors.add(:descriptor, 'must be Descriptor::Qualitative') if descriptor && descriptor.type != 'Descriptor::Qualitative'
  end
end
