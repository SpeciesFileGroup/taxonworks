# current_behavior = ActiveSupport::Deprecation.behavior
# ActiveSupport::Deprecation.behavior = lambda do |message, callstack, deprecation_horizon, gem_name|
#   return if message =~ /`serialized_attributes` is deprecated without replacement/ && callstack.any? { |m| m =~ /paper_trail/ }
#   Array.wrap(current_behavior).each { |behavior| behavior.call(message, callstack, deprecation_horizon, gem_name) }
# end
