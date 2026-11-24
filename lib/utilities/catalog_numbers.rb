# Methods that parse catalog number Strings, i.e. a namespace (typically an
# institutional coden, e.g. "INHS") and an identifier (e.g. "122345") written
# together, as on a label: "INHS 122345", "MCZ:ENT:12345", "USNMENT00123456".
#
# The core is predicting the portion of the String that is the namespace, either
# from "priors" (namespace Strings known in advance) or, without them, by heuristic.
#
# This library should be completely independent (i.e. ultimately gemifiable) from TaxonWorks.
#
# Claude Code (Opus 5.5) wrote > 50% of this module.
#
module Utilities::CatalogNumbers

  # Characters that may separate a namespace from its identifier.
  DELIMITER_CHARACTERS = '\s:\-_.#/|,'.freeze

  DELIMITERS = /[#{DELIMITER_CHARACTERS}]*/

  # Without priors: everything before the first digit is the namespace
  # (it must contain a letter), the trailing delimiters are the delimiter.
  PREDICTION = /\A(?<namespace>[^\d]*?[[:alpha:]][^\d]*?)(?<delimiter>[#{DELIMITER_CHARACTERS}]*)(?<identifier>\d.*)\z/m

  # @param string [String] a catalog number, e.g. "INHS 122345"
  # @param namespaces [Array of String] priors, namespace Strings that may
  #   start the catalog number, matched case insensitively, longest first
  # @return [Hash, nil]
  #   nil if string is blank, otherwise
  #     namespace: [String, nil] the namespace portion, as written in string
  #     identifier: [String] the remainder; the whole string if no namespace is predicted
  #     delimiter: [String, nil] what separated namespace and identifier ('' if nothing)
  #     prior: [String, nil] the prior that matched, nil if namespace is (only) a prediction
  def self.parse(string, namespaces: [])
    s = string.to_s.strip
    return nil if s.empty?

    match_prior(s, namespaces) || predict(s) || { namespace: nil, identifier: s, delimiter: nil, prior: nil }
  end

  # @return [String, nil]
  #   the identifier portion of string when (and only when) one of namespaces
  #   is matched, otherwise the whole (stripped) string
  def self.identifier(string, namespaces: [])
    r = parse(string, namespaces:)
    return nil if r.nil?

    r[:prior] ? r[:identifier] : string.to_s.strip
  end

  # @return [Hash, nil]
  def self.match_prior(string, namespaces)
    priors = Array(namespaces).map { |n| n.to_s.strip }.reject(&:empty?).uniq.sort_by { |n| -n.length }

    priors.each do |prior|
      m = string.match(/\A(?<namespace>#{Regexp.escape(prior)})(?<delimiter>#{DELIMITERS})(?<identifier>.+)\z/im)
      next if m.nil?
      next if m[:delimiter].empty? && joined?(prior[-1], m[:identifier][0])

      return { namespace: m[:namespace], identifier: m[:identifier], delimiter: m[:delimiter], prior: }
    end

    nil
  end

  # @return [Hash, nil]
  def self.predict(string)
    m = string.match(PREDICTION)
    return nil if m.nil?

    { namespace: m[:namespace], identifier: m[:identifier], delimiter: m[:delimiter], prior: nil }
  end

  # @return [Boolean]
  #   true if, without a delimiter, the two characters read as one token
  #   (e.g. "INHS" + "X..."), i.e. the prior is only part of a word or number
  def self.joined?(last_character, first_character)
    (last_character.match?(/[[:alpha:]]/) && first_character.match?(/[[:alpha:]]/)) ||
      (last_character.match?(/\d/) && first_character.match?(/\d/))
  end

  private_class_method :match_prior, :predict, :joined?

end
