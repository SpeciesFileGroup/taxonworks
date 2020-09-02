# The globally unique identifier used in wikidata
# https://www.wikidata.org/wiki/Help:Namespaces
# https://www.wikidata.org/wiki/Q43649390
#
class Identifier::Global::Wikidata < Identifier::Global

  # This is not a comprehensive map of Namespaces, but rather
  # ones envisioned of possibly being useful at some point,
  # maybe.
  #
  # As implemented we should be using 'Q' nearly everywhere, but perhaps also 'P'
  NAMESPACES = %w{Q P}.freeze

  URI_BASE = 'http://www.wikidata.org/wiki/'.freeze

  validate :namespace_format
  validate :data_exists

  def namespace_string
    identifier =~ /\A(\D+)\d+/
    $1
  end

  def uri
    URI_BASE + prefixed_identifier
  end

  def prefixed_identifier
    case namespace_string
    when 'P'
      'Property:' + identifier
    else
      identifier
    end
  end

  private

  def namespace_format
    errors.add(:identifier, 'Identifier is not prefixed with an recognized "namespace".') unless identifier =~ /\A#{NAMESPACES.join('|')}\d+/
  end

  def data_exists
    return if errors.any?
    # wikidata-client doesn't use prepended 'Prefix:' in query
    a = ::Wikidata::Item.find(identifier)
    if a.nil?
      errors.add(:identifier, "Can not find #{identifier} in wikidata.")
    end
  end

end
