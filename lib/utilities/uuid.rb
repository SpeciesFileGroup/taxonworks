# Methods for working with UUIDs. This library should be completely independent
# (i.e. ultimately gemifiable) from TaxonWorks.
module Utilities::Uuid

  FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i.freeze

  # @param string [String]
  # @return [Boolean]
  def self.uuid?(string)
    FORMAT.match?(string.to_s)
  end

end
