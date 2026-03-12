# urn:lsid:Orthoptera.speciesfile.org:TaxonName:1
#
#   • "URN"
#   • "LSID"
#   • authority identification
#   • namespace identification
#   • object identification
#   • optionally: revision identification. If revision field is omitted then the trailing colon is also omitted.
#
class Identifier::Global::Lsid < Identifier::Global
  validate :using_lsid_class

  def using_lsid_class
    return if identifier.nil?

    if identifier.match?(/\s/)
      errors.add(:identifier, "'#{identifier}' is not a valid LSID, it contains whitespace.")
      return
    end

    parts = identifier.split(':')

    unless parts.length.between?(5, 6) &&
           parts[0].casecmp('urn').zero? &&
           parts[1].casecmp('lsid').zero? &&
           parts[2].present? &&  # authority
           parts[3].present? &&  # namespace
           parts[4].present?     # object
      errors.add(:identifier, "'#{identifier}' is not a valid LSID.")
    end
  end
end
