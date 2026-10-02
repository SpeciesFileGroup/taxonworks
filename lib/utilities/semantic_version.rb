# Methods for semantic version strings of the form <major>.<minor>.<patch>,
# see https://semver.org. Pre-release and build metadata suffixes are not
# supported. This library should be completely independent of TaxonWorks.
module Utilities::SemanticVersion

  PATTERN = /\A(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)\z/

  # @param version [String]
  # @return [Boolean]
  #   true if version is <major>.<minor>.<patch>, without leading zeros,
  #   and with at least one non-zero part
  def self.valid?(version)
    m = PATTERN.match(version.to_s)
    return false if m.nil?
    m.captures.any? { |c| c != '0' }
  end

end
