# Sort keys for ::FieldOccurrence, see Queries::Sort::Base.
class Queries::FieldOccurrence::Sort < Queries::Sort::Base
  class << self
    def columns_uncached
      cols = {}

      sortable_direct_columns.each { |c, lam| cols["field_occurrence.#{c}"] = lam }

      sortable_association_columns(:collecting_event).each { |c, lam| cols["collecting_event.#{c}"] = lam }

      cols['collecting_event.geographic_area_name'] = association(:collecting_event, :geographic_area, :name)

      sortable_association_columns(:dwc_occurrence).each { |c, lam| cols["dwc_occurrence.#{c}"] = lam }

      cols.merge!(taxon_determination_columns)

      cols['identifiers.cached'] = association(:identifiers, :cached, collapse: :joined)

      cols
    end
  end
end
