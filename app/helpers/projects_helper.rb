# A controller include, need to split out session methods
# versus those that aren't
#
module ProjectsHelper

  CLASSIFIER = {
    nomenclature: [TaxonName, TaxonNameRelationship, TaxonNameClassification, TypeMaterial ],
    digitization: [CollectionObject, CollectingEvent, Loan, LoanItem, TaxonDetermination ],
    descriptive: [Otu, ControlledVocabularyTerm, Content, Observation, ObservationMatrix, Descriptor, Image, BiologicalAssociation, CharacterState, ObservationMatrixRow, ObservationMatrixColumn],
    literature: [ProjectSource, Citation, CitationTopic, Documentation, Document ],
    geospatial: [Georeference, AssertedDistribution],
  }

  CLASSIFIER_ANNOTATION =  [Identifier, Note, Tag, AlternateValue, Attribution, Confidence, Depiction ]

  def project_tag(project)
    return nil if project.nil?
    project.name
  end

  def projects_search_form
    render('/projects/quick_search_form')
  end

  def project_link(project)
    return nil if project.nil?
    l = link_to(project.name, select_project_path(project))
    project.id == sessions_current_project_id ?
    content_tag(:mark, l) :
    l
  end

  def projects_list(projects)
    projects.collect { |p| content_tag(:li, project_link(p)) }.join.html_safe
  end

  # Came from application_controller

  def invalid_object(object)
    !(!object.try(:project_id) || project_matches(object))
  end

  def project_matches(object)
    object.try(:project_id) == sessions_current_project_id
  end

  def taxonworks_classification(project_cutoff: 1000)
    result = {}
    data = Hash.new(0)

    CLASSIFIER.keys.each do |k|
      CLASSIFIER[k].each do |m|
        data[k] += m.count
      end
    end

    result[:taxonworks] = {
      data:,
      total: data.values.sum
    }

    result[:projects] = {}

    Project.all.each do |p|
      d = project_classification(p)
      next if d[:total] < project_cutoff

      result[:projects].merge!({ p.name => d })
    end

    result
  end

  def project_classification(project)
    classification = Hash.new(0)

    CLASSIFIER.keys.each do |k|
      CLASSIFIER[k].each do |m|
        classification[k] += m.where(project_id: project.id).count
      end
    end

    # Add annotations to their respective class
    CLASSIFIER_ANNOTATION.each do |m|
      field = m.column_names.select{|n| n =~ /_type/}.first
      CLASSIFIER.keys.each do |k|
        CLASSIFIER[k].each do |s|
          classification[k] += m.where(project_id: project.id, field => s.name ).count
        end
      end
    end

    return {
      data: classification,
      total: classification.values.sum
    }
  end

  def document_gb_per_year
    gb_per_year( Document.group_by_year(:created_at, format: '%Y').sum(:document_file_file_size))
  end

  def image_gb_per_year
    gb_per_year( Image.group_by_year(:created_at, format: '%Y').sum(:image_file_file_size) )
  end

  def sound_gb_per_year
    gb_per_year(
      Sound.joins(sound_file_attachment: :blob).group_by_year('sounds.created_at', format: '%Y').sum('active_storage_blobs.byte_size')
    )
  end

  def gb_per_year(sums)
    min = sums.keys.sort.first || 0
    max = sums.keys.sort.last || 0

    data = {}

    (min..max).each do |y|
      data[y] = sums[y].present? ? (sums[y].to_f / 1073741824.0).to_i : 0
    end

    data
  end

  def cumulative_gb_per_year(sums)
    d = gb_per_year(sums)

    data = {}

    t = 0
    d.each do |k,v|
      t = t + v
      data[k] = t
    end
    data
  end

  def document_cumulative_gb_per_year
    cumulative_gb_per_year(Document.group_by_year(:created_at, format: '%Y').sum(:document_file_file_size))
  end

  def image_cumulative_gb_per_year
    cumulative_gb_per_year(Image.group_by_year(:created_at, format: '%Y').sum(:image_file_file_size))
  end

  def sound_cumulative_gb_per_year
    cumulative_gb_per_year(Sound.group_by_year('sounds.created_at', format: '%Y').joins(sound_file_attachment: :blob).sum('active_storage_blobs.byte_size'))
  end

  # Cumulative Projects Created per Year
  # From chatGPT 5.0 default
  def cumulative_projects_created_per_year
    years = Project.reorder(nil).pluck(:created_at).compact.map { |t| t.in_time_zone(Time.zone).year }
    return [['Year', 'Projects']] if years.empty?

    per_year  = years.tally # TIL!
    min_year  = years.min
    max_year  = Time.zone.today.year

    cumulative = 0
    rows = (min_year..max_year).map do |y|
      cumulative += (per_year[y] || 0)
      [y, cumulative]
    end

    [['Year', 'Projects']] + rows
  end

  def week_in_review_graphs(weeks)
    content_tag(:div, '', 'data-weeks-ago': weeks, 'data-weeks-review': true)
  end

end
