# Universally Unique Identifier
#
# validates :identifier, :format => {:with => /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i, :message => 'Invalid UUID.'}
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
      /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i =~ identifier
      if $&.nil?
        errors.add(:identifier, "#{identifier} is not a valid UUID.")
      end
    end
  end
end
