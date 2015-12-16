# A human. Data only, not users. There are two classes of people: vetted and unvetted.
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
# @!attribute cached
#   @return [String]
#   @todo
#
class Person < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::SharedAcrossProjects
  include Shared::IsData

  has_paper_trail

  # Class constants
  ALTERNATE_VALUES_FOR = [:last_name, :first_name]

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank

  # after_save :update_bibtex_sources
  before_save :set_cached

  validates :type, inclusion: {in:      ['Person::Vetted', 'Person::Unvetted'],
                               message: "%{value} is not a validly_published type"}

  has_many :roles, dependent: :destroy, inverse_of: :person
  has_many :author_roles, class_name: 'SourceAuthor'
  has_many :editor_roles, class_name: 'SourceEditor'
  has_many :source_roles, class_name: 'SourceSource'
  has_many :collector_roles, class_name: 'Collector'
  has_many :determiner_roles, class_name: 'Determiner'
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor'
  has_many :type_designator_roles, class_name: 'TypeDesignator'

  # has_many :sources, through: :roles   # TODO: test and confirm dependent

  has_many :authored_sources, through: :author_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :edited_sources, through: :editor_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :human_sources, through: :source_roles, source: :role_object, source_type: 'Source::Human'
  has_many :collecting_events, through: :collector_roles, source: :role_object, source_type: 'CollectingEvent'
  has_many :taxon_determinations, through: :determiner_roles, source: :role_object, source_type: 'TaxonDetermination'
  has_many :taxon_name_authors, through: :taxon_name_author_roles, source: :role_object, source_type: 'TaxonName'
  has_many :type_material, through: :type_designator_roles, source: :role_object, source_type: 'TypeMaterial'

  #scope :named, -> (name) {where(name: name)}
  #scope :named_smith, where(last_name: 'Smith')
  scope :named_smith, -> { where(last_name: 'Smith') }
  #scope :smith_start, -> {where(last_name: start_with?('Smith'))}  # have tried multiple ways to select records where last_name like 'Smith%' without success
  scope :created_before, -> (time) { where('created_at < ?', time) }
  scope :with_role, -> (role) { includes(:roles).where(roles: {type: role}) }
  scope :ordered_by_last_name, -> { order(:last_name) }

  def name
    [self.first_name, self.prefix, self.last_name, self.suffix].compact.join(' ').strip
  end

  # @return [String]
  #   The person's name in BibTeX format (von last, Jr, first)
  def bibtex_name
    out = ''
    out << self.prefix + ' ' unless self.prefix.blank?
    out << self.last_name unless self.last_name.blank?
    out << ', ' unless out.blank? || (self.first_name.blank? && self.suffix.blank?)
    out << self.suffix unless self.suffix.blank?
    out << ', ' unless out.end_with?(', ') || self.first_name.blank? || out.blank?
    out << self.first_name unless self.first_name.blank?
    out.strip
  end

  # @return [String]
  #   The person's full last name including prefix & suffix (von last Jr)
  def full_last_name
    out = ''
    out << self.prefix + ' ' unless self.prefix.blank?
    out << self.last_name unless self.last_name.blank?
    out << ' ' + self.suffix unless self.suffix.blank?
    out.strip
  end

  def is_author?
    self.author_roles.to_a.length > 0
  end

  def is_editor?
    self.editor_roles.to_a.length > 0
  end

  def is_source?
    self.source_roles.to_a.length > 0
  end

  def is_collector?
    self.collector_roles.to_a.length > 0
  end

  def is_determiner?
    self.determiner_roles.to_a.length > 0
  end

  def is_taxon_name_author?
    self.taxon_name_author_roles.to_a.length > 0
  end

  def is_type_designator?
    self.type_designator_roles.to_a.length > 0
  end

  # TODO: TEST!
  def self.parser(name_string)
    BibTeX::Entry.new(type: :book, author: name_string).parse_names.to_citeproc['author']
  end

  # TODO: TEST!
  def self.parse_to_people(name_string)
    self.parser(name_string).collect { |n| Person::Unvetted.new(last_name: n['family'], first_name: n['given'], prefix: n['non-dropping-particle']) }
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  def set_type_if_blank
    self.type = 'Person::Unvetted' if self.type.blank?
  end

  def self.find_for_autocomplete(params)
    where('cached ILIKE ? OR cached ILIKE ? OR cached = ?', "#{params[:term]}%", "%#{params[:term]}%", params[:term]) 
  end

  def set_cached
    self.cached = self.bibtex_name if self.errors.empty?
  end

end

