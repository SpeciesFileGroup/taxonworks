current_behavior = ActiveSupport::Deprecation.behavior
ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
  return if message =~ /`serialized_attributes` is deprecated without replacement/ && callstack.any? { |m| m =~ /paper_trail/ }
  Array.wrap(current_behavior).each { |behavior| behavior.call(message, callstack) }
end
