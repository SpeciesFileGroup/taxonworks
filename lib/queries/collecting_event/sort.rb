# Sort keys for ::CollectingEvent, see Queries::Sort::Base.
class Queries::CollectingEvent::Sort < Queries::Sort::Base
  class << self
    # Frontend TableLayoutSelector emits column keys as
    # "<section>.<column>" (e.g. "collecting_event.verbatim_locality") when
    # CollectingEvent is embedded in another filter's table, and the bare
    # column name when it's the top-level filter -- register both forms for
    # every column so either usage's sort button works.
    def columns_uncached
      direct = sortable_direct_columns.merge('geographic_area_name' => association(:geographic_area, :name))
      cols = {}
      direct.each do |c, lam|
        cols[c] = lam
        cols["collecting_event.#{c}"] = lam
      end
      cols
    end
  end
end
