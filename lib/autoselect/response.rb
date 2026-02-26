# lib/autoselect/response.rb
#
# Wraps all autoselect responses into a consistent envelope.
# Config responses (no term) populate `config` and leave `response` nil.
# Term responses populate `request`, `level`, `response`, and optionally `next_level`.
#
class Autoselect::Response

  # @param config [Hash, nil] populated only for config (no-term) requests
  # @param request [Hash, nil] echo of the incoming request params
  # @param level [String, nil] the level that was queried
  # @param results [Array, nil] the formatted result items
  # @param next_level [String, nil] only present when results is empty
  # @param level_map [Array, nil] not used in output; kept for consistency
  def initialize(config:, request:, level:, results:, next_level:, level_map:)
    @config = config
    @request = request
    @level = level
    @results = results
    @next_level = next_level
    @level_map = level_map
  end

  # @return [Hash] the full response hash, suitable for `render json:`
  def as_json
    if @config
      {
        resource: @config[:resource],
        levels: @config[:levels],
        operators: @config[:operators],
        map: @config[:map],
        user_preferences: @config[:user_preferences],
        config: @config,
        response: nil
      }
    else
      h = {
        request: @request,
        level: @level,
        response: @results || [],
        config: nil
      }
      h[:next_level] = @next_level if @next_level.present?
      h
    end
  end

end
