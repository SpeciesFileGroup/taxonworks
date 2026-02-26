# lib/autoselect/base.rb
#
# Base class for all model-specific autoselect implementations.
# Mirrors the pattern of lib/queries/ where each model subclasses a shared base.
# Generated via `rails generate taxon_works:autoselect`.
#
# Usage:
#   class Autoselect::TaxonName::Autoselect < Autoselect::Base
#     ...
#   end
#
class Autoselect::Base
  include Autoselect::Operators

  # @return [String, nil] the raw search term including any operator prefix
  attr_reader :raw_term

  # @return [String, nil] the level key being queried (e.g. 'fast', 'smart')
  attr_reader :requested_level

  # @return [Integer, nil]
  attr_reader :project_id

  # @return [Integer, nil]
  attr_reader :user_id

  # @return [Hash] extra level-specific params passed through from the controller
  attr_reader :level_params

  # @param term [String, nil] raw input term (may contain operator prefix)
  # @param level [String, nil] the level key to query
  # @param project_id [Integer, nil]
  # @param user_id [Integer, nil]
  # @param kwargs [Hash] any level-specific filter params
  def initialize(term: nil, level: nil, project_id: nil, user_id: nil, **kwargs)
    @raw_term = term.presence
    @requested_level = level.presence
    @project_id = project_id
    @user_id = user_id
    @level_params = kwargs
  end

  # @return [Hash] the full response (config or term response), ready for render json:
  def response
    if raw_term.blank?
      config_response
    else
      term_response
    end
  end

  # @return [Array<Autoselect::Level>] ordered list defining the level map.
  # Subclasses must override with their own level stack.
  def levels
    raise NotImplementedError, "#{self.class} must implement #levels"
  end

  # @return [Hash] model-specific response_values for a given record.
  # Subclasses override to specify which attribute keys to inject into the parent form.
  # @param record [ApplicationRecord]
  def response_values(record)
    raise NotImplementedError, "#{self.class} must implement #response_values(record)"
  end

  # @return [String] the base URL path for this autoselect endpoint
  # Override in subclasses, e.g. '/taxon_names/autoselect'
  def resource_path
    raise NotImplementedError, "#{self.class} must implement #resource_path"
  end

  private

  def config_response
    Autoselect::Response.new(
      config: build_config,
      request: nil,
      level: nil,
      results: nil,
      next_level: nil,
      level_map: level_map_keys
    ).as_json
  end

  def term_response
    parsed = parse_operators(raw_term)
    operator = parsed[:operator]
    effective_term = parsed[:effective_term]

    level_instance = find_level(requested_level)
    results = execute_level(level_instance, effective_term, operator)
    formatted = format_results(results)

    Autoselect::Response.new(
      config: nil,
      request: { term: raw_term, level: requested_level, project_id: },
      level: requested_level,
      results: formatted,
      next_level: formatted.empty? ? next_level_key(requested_level) : nil,
      level_map: nil
    ).as_json
  end

  def build_config
    {
      resource: resource_path,
      levels: levels.map(&:metadata),
      operators: self.class.operator_definitions,
      map: level_map_keys,
      user_preferences: {}
    }
  end

  def level_map_keys
    levels.map { |l| l.key.to_s }
  end

  def find_level(key)
    levels.find { |l| l.key.to_s == key.to_s } || levels.first
  end

  def next_level_key(current_key)
    map = level_map_keys
    idx = map.index(current_key.to_s)
    return nil if idx.nil? || idx >= map.length - 1
    map[idx + 1]
  end

  def execute_level(level_instance, effective_term, operator)
    level_instance.call(
      term: effective_term,
      operator:,
      project_id:,
      user_id:,
      **level_params
    )
  end

  # Build response item hashes from an array of records.
  # Subclasses may override to handle POJOs (e.g. CoL pseudo-records with extension data).
  # @param records [Array]
  # @return [Array<Hash>]
  def format_results(records)
    records.map do |record|
      {
        id: record.id,
        label: record_label(record),
        label_html: record_label_html(record),
        info: record_info(record),
        response_values: response_values(record),
        extension: {}
      }
    end
  end

  # Subclasses override for model-specific plain-text display
  def record_label(record)
    record.to_s
  end

  # Subclasses override for HTML-decorated display
  def record_label_html(record)
    record_label(record)
  end

  # Subclasses override for secondary disambiguation metadata (rank, validity, etc.)
  def record_info(record)
    nil
  end

end
