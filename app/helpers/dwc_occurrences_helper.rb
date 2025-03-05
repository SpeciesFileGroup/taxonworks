module DwcOccurrencesHelper

  def dwc_occurrence_health_tag(dwc_occurrence)
    a = [ ]
    if dwc_occurrence.nil?
      a.push tag.span('Darwin Core Occurrence not built', class: [:feedback, 'feedback-thin', 'feedback-danger'])
    else
      a.push tag.span('Referenced data are younger than this record', class: [:feedback, 'feedback-thin', 'feedback-warning']) if dwc_occurrence.is_stale?
      a.push tag.span('A new version of the DwC builder is available', class: [:feedback, 'feedback-thin', 'feedback-warning']) if DateTime.parse(::Export::Dwca::INDEX_VERSION.last).to_i > dwc_occurrence.updated_at.to_i
    end
    a.push tag.span('Up-to-date', class: [:feedback, 'feedback-info']) if a.empty?

    a.push tag.span('TW DwcOccurrence id (internal index/use only): ' + dwc_occurrence.to_param, class: [:feedback, 'feedback-secondary'])
    a.join(' ').html_safe
  end

  def dwc_column(dwc_occurrence)
    return nil if dwc_occurrence.nil?

    r = []
    dwc_occurrence.dwc_occurrence_object.dwc_occurrence_attributes(false).each do |k, v|
      #    CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys.each do |k|
      next if [:footprintWKT].include?(k)
      if !v.blank?
        r.push tag.tr( (tag.td(k) + tag.td(v)).html_safe )
      end
    end

    r.push tag.tr( (tag.td('basisOfRecord') + tag.td(dwc_occurrence.basisOfRecord)).html_safe )
    tag.table(r.join.html_safe)
  end

  def dwc_occurrences_metadata(dwc_occurrences = nil, project_id: nil)
    records = dwc_occurrences
    project_id ||= sessions_current_project_id

    # Anticipate multiple sources of records in future (e.g. AssertedDistribution)
    collection_objects = CollectionObject.where(project_id: project_id)
    records ||= DwcOccurrence.where(project_id: project_id) # .where(dwc_occurrence_object_type: 'CollectionObject').all
    data = collection_objects.joins(:dwc_occurrence)

    a = {
      health: {
        'Kingdom rank present': TaxonName.where(project_id: project_id).with_rank_class_including('Kingdom').any?,
        'DwcOccurrence records without occurrenceID (on collection objects)': records.where(occurrenceID: nil).count,
        'Total collection objects': collection_objects.count,
        'Collection objects without UUids': collection_objects.count - collection_objects.joins(:identifiers).where("identifiers.type ilike 'Identifier::Global::Uuid%'").distinct.count,
        'Collection objects without DwcOccurrence records': collection_objects.where.missing(:dwc_occurrence).count
      },

      # updated_at takes 'updated_at > ?'  to mean "between the time provided for ? and NOW

      collection_objects: {
        record_total: collection_objects.count,
        enumerated_total: collection_objects.sum(:total),
        freshness: {
          never: collection_objects.where.missing(:dwc_occurrence).count,
          one_day: data.where("dwc_occurrences.updated_at >= ?", 1.day.ago).count,
          one_week: data.where("dwc_occurrences.updated_at <= ? and dwc_occurrences.updated_at >= ?", 1.day.ago, 1.week.ago).count,
          one_month: data.where("dwc_occurrences.updated_at <= ? and dwc_occurrences.updated_at >= ?", 1.week.ago, 1.month.ago).count,
          one_year: data.where("dwc_occurrences.updated_at <= ? and dwc_occurrences.updated_at >= ?", 1.month.ago, 1.year.ago).count,
          greater_than_one_year: data.where("dwc_occurrences.updated_at < ?", 1.year.ago).count
        },
      },

      index: { # the dwc_occurrences
        record_total: records.count,
        enumerated_total: records.sum(:individualCount),
        freshness: {
          never: 0,
          one_day: records.where("dwc_occurrences.updated_at >= ?", 1.day.ago).count,
          one_week: records.where("dwc_occurrences.updated_at <= ? and dwc_occurrences.updated_at >= ?", 1.day.ago, 1.week.ago).count,
          one_month: records.where("dwc_occurrences.updated_at <= ? and dwc_occurrences.updated_at >= ?", 1.week.ago, 1.month.ago).count,
          one_year: records.where("dwc_occurrences.updated_at <= ? and dwc_occurrences.updated_at >= ?", 1.month.ago, 1.year.ago).count,
          greater_than_one_year: records.where("dwc_occurrences.updated_at < ?", 1.year.ago).count
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
      .joins(collecting_events: [:collection_objects])
      .joins("JOIN dwc_occurrences dwo on dwo.dwc_occurrence_object_id = collection_objects.id AND dwo.dwc_occurrence_object_type = 'CollectionObject'")
      .where(dwo: {project_id: project_id})
      .order(:cached)

    with_global_id = a.where("identifiers.type ILIKE 'Identifier::Global%'").distinct.pluck(:id, :cached)
    without_global_id =  a.where("(identifiers.id is null) OR identifiers.type not ILIKE 'Identifier::Global%'").distinct.pluck(:id, :cached)

    return {
      without_global_id: without_global_id,
      with_global_id: with_global_id
    }
  end

  # @return String html table or empty
  def is_stale_metadata_tag(dwc_occurrence)
    d = dwc_occurrence.is_stale_metadata
    u = dwc_occurrence.updated_at
    return '' if d.empty?

    tag.table(
      d.collect{|k,v|
        tag.tr(
          ( tag.td(k.to_s.humanize) + tag.td( (u < v) ? tag.span(v, class: [:feedback, 'feedback-thin', 'feedback-danger']) : distance_of_time_in_words(u, v) ) ).html_safe
        )
      }.join.html_safe
    )
  end

  def dwc_determined_to_rank(otu, project_id)
    d = {
      kingdom: 0,
      dwcClass: 0,
      order: 0,
      family: 0,
      genus: 0,
      specificEpithet: 0
    }

    # TODO: validate

    return d if otu.taxon_name.nil?
    a = ::Queries::TaxonName::Filter.new(
      taxon_name_id: otu.taxon_name_id,
      descendants: true ).all

    b = ::Queries::CollectionObject::Filter.new({})
    b.taxon_name_query = a

    q = ::Queries::DwcOccurrence::Filter.new( project_id: )
    q.collection_object_query = b

    k = d.keys

    k.each do |r|
      q.empty_rank = k[k.index(r)..k.length]
      d[r] = q.all.select(*k, :individualCount).sum(:individualCount)
    end

    d[:class] = d[:dwcClass]
    d[:species] = d[:specificEpithet]

      d.delete(:dwcClass)
      d.delete(:specificEpithet)
      d
  end

end
