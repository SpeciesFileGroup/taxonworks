# lib/autoselect/level.rb
#
# Base class for all autoselect levels.
# Each level is a named, independent search strategy.
# Levels do not fork; they are executed sequentially by the Autoselect base class
# when their predecessor returns empty results (the fuse mechanic).
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

end
