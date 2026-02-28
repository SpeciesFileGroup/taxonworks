# lib/autoselect/operators.rb
#
# Provides operator parsing for autoselect model classes.
# Included by Autoselect and overrideable per-model.
# Operators are `!`-prefixed inline commands in the term string.
# Only the first matching operator is extracted; the rest of the string becomes
# the effective_term.
#
# Order matters: more specific patterns must come before less specific ones.
# `recent_mine` (!rm) must precede `recent` (!r) to avoid `!r` consuming `!rm`.
#
module Autoselect::Operators

  OPERATORS = {
    recent_mine:   { pattern: /\A!rm/,     client_only: false, trigger: '!rm', description: 'Recent records by current user' },
    recent:        { pattern: /\A!r/,      client_only: false, trigger: '!r',  description: 'Recent records (project-wide)' },
    help:          { pattern: /\A!\?/,     client_only: false, trigger: '!?',  description: 'Show help overlay' },
    new_record:    { pattern: /\A!n/,      client_only: true,  trigger: '!n',  description: 'Create a new record' },
    level_hash:    { pattern: /\A!#/,      client_only: true,  trigger: '!#',  description: 'Jump to first level' },
    level_number:  { pattern: /\A!(\d+)/,  client_only: true,  trigger: '!N',  description: 'Jump to level N' },
  }.freeze

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # @return [Array<Hash>] metadata array for the config response `operators` key
    def operator_definitions
      operator_map.map do |key, definition|
        {
          key: key.to_s,
          trigger: definition[:trigger],
          description: definition[:description],
          client_only: definition[:client_only]
        }
      end
    end

    # @return [Hash] the operator definitions for this model.
    # Override in model-specific operators module to add/remove operators.
    def operator_map
      Autoselect::Operators::OPERATORS
    end
  end

  # @param term [String] the raw term including any operator prefix
  # @return [Hash] { operator: Symbol or nil, effective_term: String }
  def parse_operators(term)
    return { operator: nil, effective_term: term.to_s.strip } if term.blank?

    self.class.operator_map.each do |key, definition|
      if m = term.match(definition[:pattern])
        effective_term = term[m[0].length..].strip
        return { operator: key, effective_term: }
      end
    end

    { operator: nil, effective_term: term.strip }
  end

end
