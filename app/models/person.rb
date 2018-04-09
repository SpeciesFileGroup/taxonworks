# A human. Data only, not users. There are two classes of people: vetted and unvetted.
# !! People are only related to data via Roles.
#
# A vetted person
# * Has two or more roles
# * Has one or more annotations
#
# An unvetted person
# * Has no or 1 role
# * Has no annotations
#
# A unvetted person becomes automatically vetted when they have > 1 roles or they
# have an annotation associated with them.
#
# @!attribute type
#   @return [String]
#   Person::Vetted or Person::Unvetted
#
# @!attribute last_name
#   @return [String]
#   the last/family name
#
# @!attribute first name
#   @return [String]
#   the first name, includes initials if the are provided
#
# @!attribute suffix
#   @return [String]
#   string following the *last/family* name
#
# @!attribute year_active_start
#   @return [Integer]
#     (rough) starting point of when person made scientific assertions that were dissemenated (i.e. could be seen by others)
#
# @!attribute year_active_end
#   @return [Integer]
#     (rough) ending point of when person made scientific assertions that were dissemenated (i.e. could be seen by others)
#
# @!attribute year_born
#   @return [Integer]
#     born on
#
## @!attribute year_died
#   @return [Integer]
#     year died
#
# @!attribute cached
#   @return [String]
#      full name
#
class Person < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail
  include Shared::IsData

  ALTERNATE_VALUES_FOR = [:last_name, :first_name].freeze

  # @return [Boolean]
  #   When true cached values are not built
  attr_accessor :no_cached

  validates_presence_of :last_name, :type

  validates :year_born, inclusion: { in: 0..Time.now.year }, allow_nil: true
  validates :year_died, inclusion: { in: 0..Time.now.year }, allow_nil: true
  validates :year_active_start, inclusion: { in: 0..Time.now.year }, allow_nil: true
  validates :year_active_end, inclusion: { in: 0..Time.now.year }, allow_nil: true

  validate :died_after_born
  validate :activity_ended_after_started
  validate :not_active_after_death
  validate :not_active_before_birth
  validate :not_gandalf

  before_validation :set_type_if_blank

  after_save :set_cached, unless: Proc.new {|n| n.no_cached || errors.any? }

  validates :type, inclusion: {
    in: ['Person::Vetted', 'Person::Unvetted'],
    message: '%{value} is not a validly_published type'}

  has_many :roles, dependent: :destroy, inverse_of: :person
  has_many :author_roles, class_name: 'SourceAuthor'
  has_many :editor_roles, class_name: 'SourceEditor'
  has_many :source_roles, class_name: 'SourceSource'
  has_many :collector_roles, class_name: 'Collector'
  has_many :determiner_roles, class_name: 'Determiner'
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor'
  has_many :type_designator_roles, class_name: 'TypeDesignator'
  has_many :georeferencer_roles, class_name: 'Georeferencer'

  # has_many :sources, through: :roles   # TODO: test and confirm dependent

  has_many :authored_sources, through: :author_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :edited_sources, through: :editor_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :human_sources, through: :source_roles, source: :role_object, source_type: 'Source::Human'
  has_many :collecting_events, through: :collector_roles, source: :role_object, source_type: 'CollectingEvent'
  has_many :taxon_determinations, through: :determiner_roles, source: :role_object, source_type: 'TaxonDetermination'
  has_many :authored_taxon_names, through: :taxon_name_author_roles, source: :role_object, source_type: 'TaxonName'
  has_many :type_material, through: :type_designator_roles, source: :role_object, source_type: 'TypeMaterial'
  has_many :georeferences, through: :georeferencer_roles, source: :role_object, source_type: 'Georeference'

  scope :created_before, -> (time) { where('created_at < ?', time) }
  scope :with_role, -> (role) { includes(:roles).where(roles: {type: role}) }
  scope :ordered_by_last_name, -> { order(:last_name) }

  # @return [Boolean]
  #   !! overwrites IsData#is_in_use?
  def is_in_use?
    roles.any?
  end

  # @return [String]
  def name
    [first_name, prefix, last_name, suffix].compact.join(' ')
  end

  # @return [String]
  #   The person's name in BibTeX format (von last, Jr, first)
  def bibtex_name
    out = ''

    out << prefix + ' ' unless prefix.blank?
    out << last_name unless last_name.blank?
    out << ', ' unless out.blank? || (first_name.blank? && suffix.blank?)
    out << suffix unless suffix.blank?

    out << ', ' unless out.end_with?(', ') || first_name.blank? || out.blank?
    out << first_name unless first_name.blank?
    out.strip
  end

  # @return [String]
  #   The person's full last name including prefix & suffix (von last Jr)
  def full_last_name
    [prefix, last_name, suffix].compact.join(' ')
  end

  # @return [Boolean]
  def is_author?
    author_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_editor?
    editor_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_source?
    source_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_collector?
    collector_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_determiner?
    determiner_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_taxon_name_author?
    taxon_name_author_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_type_designator?
    type_designator_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_georeferencer?
    georeferencer_roles.to_a.length > 0
  end

  # @param [String] name_string
  # @return [Array] of Hashes
  #   use citeproc to parse strings
  def self.parser(name_string)
    BibTeX::Entry.new(type: :book, author: name_string).parse_names.to_citeproc['author']
  end

  # @param [String] name_string
  # @return [Array] of People
  #    return people for name strings
  def self.parse_to_people(name_string)
    parser(name_string).collect{|n| Person::Unvetted.new(last_name: n['family'],
                                                         first_name: n['given'],
                                                         prefix: n['non-dropping-particle']) }
  end

  # @param [Person] person to which this instance is to be compared
  # @return [Boolean]
  def similar(person)

  end

  # @param [Person] person to which this instance is to be compared
  # @return [Boolean]
  def identical(person)

  end

  protected

  # @return [Ignored]
  def died_after_born
    errors.add(:year_born, 'is older than died year') if year_born && year_died && year_born > year_died
  end

  # @return [Ignored]
  def activity_ended_after_started
    errors.add(:year_active_start, 'is older than died year') if year_active_start && year_active_end && year_active_start > year_active_end
  end

  # @return [Ignored]
  def not_active_after_death
    errors.add(:year_active_start, 'is older than year of death') if year_active_start && year_died && year_active_start > year_died
    errors.add(:year_active_end, 'is older than year of death') if year_active_end && year_died && year_active_end > year_died
  end

  # @return [Ignored]
  def not_active_before_birth
    errors.add(:year_active_start, 'is younger than than year of birth') if year_active_start && year_born && year_active_start < year_born
    errors.add(:year_active_end, 'is younger than year of birth') if year_active_end && year_born && year_active_end < year_born
  end

  # @return [Ignored]
  def not_gandalf
    errors.add(:base, 'fountain of eternal life does not exist yet') if year_born && year_died && year_died - year_born > 117
  end

  # TODO: deprecate this, always set explicitly
  # @return [Ignored]
  def set_type_if_blank
    self.type = 'Person::Unvetted' if self.type.blank?
  end

  # @return [Ignored]
  def set_cached
    update_column(:cached, bibtex_name)
    set_taxon_name_cached_author_year
  end

  # @return [Ignored]
  def set_taxon_name_cached_author_year
    if saved_change_to_last_name? || saved_change_to_prefix? || saved_change_to_suffix?
      authored_taxon_names.reload.each do |t|
        t.send(:set_cached) # TODO: optimize, perhaps on set_author_year
      end
    end
  end

end

