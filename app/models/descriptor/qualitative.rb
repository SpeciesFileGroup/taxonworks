# A descriptor that has qualitative states. For example a phylogenetic character.  Also used for descriptive matrices.
# Note that presence/absence descriptors have their own subclass and should be represented there to maximize utility.
#
class Descriptor::Qualitative < Descriptor 

  has_many :character_states, foreign_key: :descriptor_id, inverse_of: :descriptor, dependent: :destroy

  accepts_nested_attributes_for :character_states, allow_destroy: true, reject_if: :reject_character_states

  protected

  def reject_character_states(attributes)
    attributes[:name].blank? || attributes[:label].blank?
  end
end
