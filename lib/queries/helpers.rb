module Queries::Helpers

  # @params params []
  # @params attribute [Symbol]
  def boolean_param(params, attribute)
    (params[attribute]&.downcase == 'true' ? true : false) if !params[attribute].nil?
  end
end
