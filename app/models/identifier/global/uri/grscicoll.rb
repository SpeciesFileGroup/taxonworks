
# See, for example https://www.gbif.org/grscicoll/collection/160d4494-1658-4326-9550-3c7eb9fcac48
class Identifier::Global::Uri::Grscicoll < Identifier::Global::Uri
  VALID_ROOTS = %w{
    http://grscicoll.org
    http://grbio.org
    http://biocol.org
  }

  validate :used_on_repository
  validate :references_a_known_form

  protected

  def references_a_known_form
    errors.add(:identifier, 'Does not appear to contain grscicoll.org or grbio.org.') if !(identifier =~ /^#{VALID_ROOTS.join('|')}/)
  end

  def used_on_repository
    errors.add(:identifier_object_type, 'Grscicoll identifiers May only be used on Repositories') if identifier_object_type != 'Repository'
  end

end
