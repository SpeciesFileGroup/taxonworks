# A human source can be either a single individual person or a group of people (e.g. Tom, Dick and
# Harry decided that this species is the same as that but haven't written it up yet.)
class Source::Human < Source

  IGNORE_IDENTICAL = [:serial_id, :address, :annote, :booktitle, :chapter, :crossref,
                      :edition, :editor, :howpublished, :institution, :journal, :key,
                      :month, :note, :number, :organization, :pages, :publisher, :school,
                      :series, :title, :volume, :doi, :abstract, :copyright, :language,
                      :stated_year, :verbatim, :bibtex_type, :day, :year, :isbn, :issn,
                      :verbatim_contents, :verbatim_keywords, :language_id, :translator,
                      :year_suffix, :url, :author, :cached, :cached_author_string,
                      :cached_nomenclature_date].freeze

  IGNORE_SIMILAR = IGNORE_IDENTICAL.dup.freeze

  has_many :source_source_roles, -> { order('roles.position ASC') }, class_name: 'SourceSource',
           as: :role_object, validate: true

  has_many :people, -> { order('roles.position ASC') },
           through: :source_source_roles, source: :person, validate: true

  accepts_nested_attributes_for :people, :source_source_roles, allow_destroy: true

  validate :at_least_one_person_is_provided

  # @return [String]
  def authority_name
    Utilities::Strings.authorship_sentence(
      people.collect { |p| p.last_name }
    )
  end

  # TODO: Special case of Source::Human needs to check for roles of 'SourceSource' matching.
  # @param [Hash] attr of matchable attributes
  # @return [Scope]
  def self.similar(attr)
    Source::Human.none
  end

  # @param [Hash] attr of matchable attributes
  # @return [Scope]
  def self.identical(attr)
    Source::Human.none
  end

  # @return [Scope]
  def similar
    Source::Human.none
  end

  # @return [Scope]
  def identical
    Source::Human.none
  end

  def self.by_person(person_ids = [ ], table_alias = nil)
    return Source::Human.none if person_ids.empty?

    s  = Source::Human.arel_table
    sr = Role.arel_table

    a = s.alias("a_#{table_alias}")

    b = s.project(a[Arel.star]).from(a)
      .join(sr)
      .on(sr['role_object_id'].eq(a['id']))

    i = 0
    person_ids.each_with_index do |person_id, i|
      sr_a = sr.alias("#{table_alias}_#{i}")
      b = b.join(sr_a).on(
        sr_a['role_object_id'].eq(a['id']),
        sr_a['person_id'].eq(person_id),
        sr_a['type'].eq('SourceSource')
      )
      i += 1
    end

    b = b.group(a['id']).having(sr['role_object_id'].count.eq(person_ids.count))
    b = b.as("z_#{table_alias}")

    Source::Human.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(s['id']))))
  end

  protected

  def get_cached
    [authority_name, year].compact.join(', ')
  end

  # @return [Ignored]
  def set_cached
    update_column(:cached, get_cached)
  end

  # @return [Ignored]
  def at_least_one_person_is_provided
    if people.size < 1 && source_source_roles.size < 1 && roles.size < 1 # size not count
      errors.add(:base, 'at least one person must be provided')
    end
  end
end
