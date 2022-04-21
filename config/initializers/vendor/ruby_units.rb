::RubyUnits::Unit.define("count") do |count|
  count.definition   = ::RubyUnits::Unit.new("1")        # anything that results in a Unit object
  count.aliases      = %w{count total}      # array of synonyms for the unit
  count.display_name = "Count"              # How unit is displayed when output
end

::RubyUnits::Unit.define("ratio") do |count|
  count.definition   = ::RubyUnits::Unit.new("1")
  count.aliases      = %w{ratio}
  count.display_name = "Ratio"
end

::RubyUnits::Unit.define("mg") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 g/1000")
  count.aliases      = %w{mg milligram}
  count.display_name = "milligram"
end

::RubyUnits::Unit.define("µg") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 mg/1000")
  count.aliases      = %w{ug nanogram µg}
  count.display_name = "µg"
end

::RubyUnits::Unit.define("ng") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 µg/1000")
  count.aliases      = %w{ng nanogram}
  count.display_name = "ng"
end

::RubyUnits::Unit.define("ml") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 l/1000")
  count.aliases      = %w{ml milliliter millilitre}
  count.display_name = "ml"
end

::RubyUnits::Unit.define("µl") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 ml/1000")
  count.aliases      = %w{ul µl microlitre microliter}
  count.display_name = "µl"
end

::RubyUnits::Unit.define("nl") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 µl/1000")
  count.aliases      = %w{nl nanolitre nanoliter}
  count.display_name = "nl"
end

::RubyUnits::Unit.define("ng/µl") do |count|
  count.definition   = ::RubyUnits::Unit.new("1 ng/µl")
  count.aliases      = %w{ng/ul ng/µl nanogram/microliter}
  count.display_name = "ng/µl"
end
