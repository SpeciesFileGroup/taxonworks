# Preloads for the filter.json responses of CollectionObject and
# FieldOccurrence, matched to the requested `extend`s, so a table page renders
# in a fixed number of queries however many rows it has.
module OccurrenceFilterIncludes
  extend ActiveSupport::Concern

  private

  # @param records [ActiveRecord::Relation]
  # @param associations [Array<Symbol>] associations preloaded when their own
  #   name is extended
  def add_occurrence_includes(records, associations)
    x = associations.select { |e| helpers.extend_response_with(e.to_s) }
    records = records.includes(*x) if x.any?

    if helpers.extend_response_with('collecting_event')
      records = records.includes(collecting_event: collecting_event_includes)
    end

    if helpers.extend_response_with('taxon_determinations')
      records = records.includes(
        taxon_determinations: [:otu, determiner_roles: [:person, :organization]]
      )
    end

    records
  end

  # What the nested collecting event renders, see collecting_events/_attributes.
  def collecting_event_includes
    ce_includes = [:identifiers]
    ce_includes.push(collector_roles: :person) if helpers.extend_response_with('roles')
    if helpers.extend_response_with('geographic_area_name') || helpers.extend_response_with('geographic_area')
      ce_includes.push(:geographic_area)
    end
    ce_includes
  end
end
