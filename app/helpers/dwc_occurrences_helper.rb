module DwcOccurrencesHelper

  def dwc_occurrence_health_tag(dwc_occurrence)
    a = [ ]
    if dwc_occurrence.nil?
      a.push tag.span('Darwin Core Occurrence not built', class: [:feedback, 'feedback-thin', 'feedback-danger'])
    else
      a.push tag.span('Referenced data are younger than this record', class: [:feedback, 'feedback-thin', 'feedback-warning']) if dwc_occurrence.is_stale?
      a.push tag.span('A new version of the DwC builder is available', class: [:feedback, 'feedback-thin', 'feedback-warning']) if Time.new(::Export::Dwca::INDEX_VERSION.last) > dwc_occurrence.updated_at
    end
    a.push tag.span('Up-to-date', class: [:feedback, 'feedback-info']) if a.empty?
    a.join().html_safe
  end

  def dwc_column(dwc_occurrence)
    return nil if dwc_occurrence.nil?

    r = []
    CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys.each do |k|
      next if k == :footprintWKT
      if v = dwc_occurrence.send(k)
        r.push tag.tr( (tag.td(k) + tag.td(v)).html_safe )
      end
    end
    tag.table(r.join.html_safe)
  end

  def dwc_occurrences_metadata(dwc_occurrences = nil, project_id: nil)
    records = dwc_occurrences
    project_id ||= sessions_current_project_id

    # Anticipate multiple sources of records in future (e.g. AssertedDistribution)
    records ||= DwcOccurrence.where(project_id: project_id).where(dwc_occurrence_object_type: 'CollectionObject').all
    data = CollectionObject.where(project_id: project_id)

    a = {
      health: {
        'Kingdom rank present': TaxonName.where(project_id: project_id).with_rank_class_including('Kingdom').any?
      },

      collection_objects: {
        record_total: data.count,
        enumerated_total: data.sum(:total),
        freshness: {
          never: data.left_outer_joins(:dwc_occurrence).where(dwc_occurrences: {id: nil}).count,
          one_day: data.where("updated_at > ?", 1.day.ago).count,
          one_week: data.where("updated_at > ?", 1.week.ago).count,
          one_month: data.where("updated_at > ?", 1.month.ago).count,
          one_year: data.where("updated_at > ?", 1.year.ago).count,
        },
      },

      index: { # the dwc_occurrences
        record_total: records.count,
        enumerated_total: records.sum(:individualCount),
        freshness: {
          one_day: records.where("updated_at > ?", 1.day.ago).count,
          one_week: records.where("updated_at > ?", 1.week.ago).count,
          one_month: records.where("updated_at > ?", 1.month.ago).count,
          one_year: records.where("updated_at > ?", 1.year.ago).count,
        }
      }
    }
  end

  def collector_global_id_metadata(dwc_occurrences = nil, project_id = nil)
    records = dwc_occurrences
    project_id ||= sessions_current_project_id

    # Anticipate multiple sources of records in future (e.g. AssertedDistribution)
    records ||= ::DwcOccurrence.where(project_id: project_id)

    a = ::Person
      .left_joins(:identifiers)
      .joins(:dwc_occurrences)
      .order(:cached)
      .merge(records)

    with_global_id = a.where("identifiers.type ILIKE 'Identifier::Global%'").distinct.pluck(:id, :cached)
    without_global_id =  a.where("(identifiers.id is null) OR identifiers.type not ILIKE 'Identifier::Global%'").distinct.pluck(:id, :cached)

    return {
      without_global_id: without_global_id,
      with_global_id: with_global_id
    }
  end


end
