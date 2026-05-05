# Universally Unique Identifier
#
class Identifier::Global::Uuid < Identifier::Global
  attr_accessor :is_generated

  before_validation :generate_uuid, if:  -> { self.is_generated }

  validate :using_uuid_class

  def generate_uuid
    write_attribute(:identifier, SecureRandom.uuid)
  end

  def using_uuid_class
    unless identifier.nil?
      errors.add(:identifier, "#{identifier} is not a valid UUID.") unless Utilities::Uuid.uuid?(identifier)
    end
  end
end
