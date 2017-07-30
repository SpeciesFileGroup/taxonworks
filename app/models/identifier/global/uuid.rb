# Universally Unique Identifier
#
# validates :identifier, :format => {:with => /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i, :message => 'Invalid UUID.'}
#
class Identifier::Global::Uuid < Identifier::Global
  validate :using_uuid_class

  def using_uuid_class
    unless identifier.nil?
      /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i =~ identifier
      if $&.nil?
        errors.add(:identifier, "#{identifier} is not a valid UUID.")
      end
    end
  end
end
