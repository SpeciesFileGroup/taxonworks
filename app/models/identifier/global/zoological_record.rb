# Zoological Record is a type of Web of Science ID namespaced with ZOOREC:ZOOR
class Identifier::Global::ZoologicalRecord < Identifier::Global::WebOfScience

  validate :namespace_format

  private

  # Examples: ZOOR15303016510, ZOOR15307044227
  def namespace_format
    errors.add(:identifier, 'Identifier is not prefixed with an recognized "namespace".') unless identifier =~ /^ZOOREC:ZOOR\d{11}/
  end

end
