# Serial - represents a journal or other serial publication
# Currently the only attribute is the full_name.
# It will support abbreviations through Shared::AlternateValues.
# Serials are Notable, Taggable, and Identifiable.
#
class Serial < ActiveRecord::Base
  # Include statements, and acts_as_type
  include SoftValidation
  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::Notable
  include Shared::AlternateValues
# TODO should serials have dataAttributes?
#  include Shared::DataAttributes
  include Shared::Taggable

  # Class constants
  # Class variables
  # Callbacks
  # Associations, in order: belongs_to, has_one,has_many
  # Scopes, clustered by function

  # "Hard" Validations
  validate :not_empty

  # "Soft" Validations
  soft_validate(:sv_duplicate?)

  # Getters/Setters

  # Class methods

  # Instance methods
  def duplicate?
    # Boolean is there another serial with the same name?
    #TODO write this
    False
  end
  protected


  def sv_duplicate?
    if self.duplicate?
      soft_validations.add(:full_name, 'There is another serial with this name in the database.')
    end
  end

  def not_empty
     # a serial must have content in some field
    !self.full_name.blank?
  end

end
