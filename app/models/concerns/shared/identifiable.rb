module Shared::Identifiable
  extend ActiveSupport::Concern
  included do
    has_many :identifiers, as: :identified_object, validate: false
    accepts_nested_attributes_for :identifiers

    #scope :creator_missing_first_name, -> { where(people: {first_name: nil}).joins(:creator)}
    #scope :created_by,  lambda {|person| where("created_by_id = ?", person) }
    #scope :modified_by, lambda {|person| where("last_updated_by_id = ?", person) }
  end

  def identified?
    self.identifiers.size > 0
  end

  protected

  # This code wasn't asked for in the Tutorial
  # def set_creator
  #   self.created_by_id = $person_id
  #   set_updater
  # end

  # def set_updater
  #   self.last_updated_by_id = $person_id if self.changed?
  # end

end
