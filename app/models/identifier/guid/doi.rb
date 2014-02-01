class Identifier::Guid::Doi < Identifier::Guid
=begin
  per  http://www.doi.org/doi_handbook/2_Numbering.html section 2.2  on 1/31/2014
  The DOI syntax shall be made up of a DOI prefix and a DOI suffix separated by a forward slash.
  There is no defined limit on the length of the DOI name, or of the DOI prefix or DOI suffix.
  The DOI name is case-insensitive and can incorporate any printable characters from the legal graphic characters
    of Unicode. Further constraints on character use (e.g. use of language-specific alphanumeric characters) can
    be defined for an application by the ISO 26324 Registration Authority.
  The combination of a unique DOI prefix (assigned to a particular DOI registrant) and a unique DOI suffix
    (provided by that registrant for a specific object) is unique, and so allows the de-centralized allocation of
    DOI names.
  The DOI name is an opaque string for the purposes of the DOI system. No definitive information may be inferred
    from the specific character string of a DOI name. In particular, the inclusion in a DOI name of any registrant
    code allocated to a specific registrant does not provide evidence of the ownership of rights or current management
    responsibility of any intellectual property in the referent. Such information may be asserted in the associated
    metadata.
=end
  validates :identifier, :format => {:with => /\A.*\/.*\z/, :message => 'Invalid DOI.'}
end
