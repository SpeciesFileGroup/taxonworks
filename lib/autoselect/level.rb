# lib/autoselect/level.rb
#
# Base class for all autoselect levels.
# Each level is a named, independent search strategy.
# Levels do not fork; they are executed sequentially by the Autoselect base class
# when their predecessor returns empty results (the fuse mechanic).
#
# Rendering responsibility:
#   Internal levels use the default record_* methods, which delegate to
#   per-model helpers in app/helpers/ (e.g. taxon_name_autoselect_tag).
#   External levels override record_* directly — they must not rely on the
#   helper pattern because their records are POJOs, not AR instances.
#
class Autoselect::Level

  DEFAULT_FUSE_MS = 600
  EXTERNAL_FUSE_MS = 2000
  MINIMUM_RESULTS = 1  # escalate when result count < this value

  # @return [Symbol] unique identifier for this level, e.g. :fast, :smart
  def key
    raise NotImplementedError, "#{self.class} must implement #key"
  end

  # @return [String] human-readable label
  def label
    raise NotImplementedError, "#{self.class} must implement #label"
  end

  # @return [String] description shown in help overlay
  def description
    raise NotImplementedError, "#{self.class} must implement #description"
  end

  # @return [Boolean] true when this level calls outside the database
  def external?
    false
  end

  # @return [Integer] milliseconds for the fuse animation before auto-escalating
  def fuse_ms
    external? ? EXTERNAL_FUSE_MS : DEFAULT_FUSE_MS
  end

  # @return [Integer] minimum results to suppress escalation
  def minimum_results
    MINIMUM_RESULTS
  end

  # Execute the level search.
  # @param term [String] the effective search term (operators stripped)
  # @param operator [Symbol, nil] parsed operator if any
  # @param project_id [Integer, nil]
  # @param user_id [Integer, nil]
  # @param kwargs [Hash] level-specific params
  # @return [Array] of model instances (ActiveRecord records or POJOs)
  def call(term:, operator: nil, project_id: nil, user_id: nil, **kwargs)
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  # @return [Hash] the metadata representation included in config responses
  def metadata
    {
      key: key.to_s,
      label:,
      description:,
      external: external?,
      fuse_ms:
    }
  end

  # Plain-text label shown in the input after selection (no HTML).
  # Delegates to label_for_<model> in app/helpers by default.
  # External levels must override this.
  def record_label(record)
    h = ApplicationController.helpers
    helper = "label_for_#{model_key}"
    return h.send(helper, record).to_s if h.respond_to?(helper)
    record.to_s
  end

  # HTML label shown left-justified in the dropdown row.
  # Delegates to <model>_autoselect_tag in app/helpers by default.
  # External levels must override this.
  def record_label_html(record)
    h = ApplicationController.helpers
    helper = "#{model_key}_autoselect_tag"
    return h.send(helper, record).to_s if h.respond_to?(helper)
    record_label(record)
  end

  # Array of disambiguation strings shown right-justified in the dropdown row.
  # Delegates to <model>_autoselect_info in app/helpers by default.
  # External levels must override this.
  def record_info(record)
    h = ApplicationController.helpers
    helper = "#{model_key}_autoselect_info"
    return h.send(helper, record) if h.respond_to?(helper)
    []
  end

  # HTML string joining record_info with &nbsp;
  def record_info_html(record)
    record_info(record).compact.join('&nbsp;')
  end

  private

  # Derives the snake_case model name from the level's class namespace.
  # Autoselect::TaxonName::Levels::Fast → 'taxon_name'
  def model_key
    self.class.name.split('::')[-3].underscore
  end

end
