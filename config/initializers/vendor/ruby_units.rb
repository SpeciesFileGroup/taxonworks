::RubyUnits::Unit.define("count") do |count|
  count.definition   = ::RubyUnits::Unit.new("1")        # anything that results in a Unit object
  count.aliases      = %w{count total}      # array of synonyms for the unit
  count.display_name = "Count"              # How unit is displayed when output
end
