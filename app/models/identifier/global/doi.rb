# Digital Object Identifier
#
#   per  http://www.doi.org/doi_handbook/2_Numbering.html
# Section 2.2  on 1/31/2014
#   The DOI syntax shall be made up of a DOI prefix and a DOI suffix separated by a forward slash.
#   There is no defined limit on the length of the DOI name, or of the DOI prefix or DOI suffix.
#   The DOI name is case-insensitive and can incorporate any printable characters from the legal graphic characters
#     of Unicode. Further constraints on character use (e.g. use of language-specific alphanumeric characters) can
#     be defined for an application by the ISO 26324 Registration Authority.
#   The combination of a unique DOI prefix (assigned to a particular DOI registrant) and a unique DOI suffix
#     (provided by that registrant for a specific object) is unique, and so allows the de-centralized allocation of
#     DOI names.
#   The DOI name is an opaque string for the purposes of the DOI system. No definitive information may be inferred
#     from the specific character string of a DOI name. In particular, the inclusion in a DOI name of any registrant
#     code allocated to a specific registrant does not provide evidence of the ownership of rights or current management
#     responsibility of any intellectual property in the referent. Such information may be asserted in the associated
#     metadata.
# Section 2.2.2
#   General
#     The DOI prefix shall be composed of a directory indicator followed by a registrant code. These two components
#       shall be separated by a full stop (period).
#
#   Directory indicator
#
#     The directory indicator shall be "10". The directory indicator distinguishes the entire set of character strings
#       (prefix and suffix) as digital object identifiers within the resolution system.
#
#   Registrant code
#
#     The second element of the DOI prefix shall be the registrant code. The registrant code is a unique string assigned
#        to a registrant.
#
class Identifier::Global::Doi < Identifier::Global
  validates :identifier, format: {with: /\A(10)\.([\d\.]*)\/.*\z/, message: 'Invalid DOI.'}

  before_validation :handle_prefixes

  protected

  DOI_MATCH = /^(doi:|http(s)?:\/\/(dx\.)?doi\.org\/)/i

  # permit and remove various preambles: 'doi:', 'http://dx.doi.org/', 'https://doi.org/'
  def handle_prefixes
    return identifier if identifier.blank?
    identifier.strip!
    identifier.gsub!(DOI_MATCH, '') if identifier
  end

  def self.preface_doi(raw)
    return raw if raw.blank?
    raw.strip!
    return raw if raw.start_with?('http') # already a URL?
    # probably a raw DOI
    'https://doi.org/' + raw
  end

end
