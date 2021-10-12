# A Source is the metadata that identifies the origin of some information/data.
#
# The primary purpose of Source metadata is to allow the user to find the source, that's all.
#
# See https://en.wikipedia.org/wiki/BibTeX for a definition of attributes, in nearly all cases they are 1:1 with the TW model.  We use this https://github.com/inukshuk/bibtex-ruby awesomeness.  See https://github.com/inukshuk/bibtex-ruby/tree/master/lib/bibtex/entry, in particular rdf_converter.rb for the types of field managed.
#
#
# @!attribute serial_id
#   @return [Integer]
#     The TaxonWorks Serial
#
# @!attribute address
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute annote
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute author
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute booktitle
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute chapter
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute crossref
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute edition
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute editor
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute howpublished
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute institution
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute journal
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute key
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute month
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#      stored as a three letter value, see ::VALID_BIBTEX_MONTHS
#
# @!attribute note
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute number
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute organization
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute pages
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute publisher
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute school
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute series
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute title
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
## @!attribute year
#   @return [Integer]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute type
#   @return [String]
#     An exception to the 1:1 modelling.  We retain for Rails STI usage. Either Source::Verbatim or Source::Bibtex.
#     The former can only consist of a single field (the full citation as a string).
#     The latter is a Bibtex model.  See "bibtex_type" for the bibtex attribute "type".
#
# @!attribute bibtex_type
#   @return [String]
#     alias for "type" in the bibtex framework  see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute volume
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute doi
#   @return [String]
#    When provided also cloned to an Identifier::Global. See https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute abstract
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute copyright
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute language
#   @return [String]
#    see https://en.wikipedia.org/wiki/BibTeX#Field_types
#
# @!attribute stated_year
#   @return [String]
#    See source/bibtex.rb
#    TODO: Why is this character but year is int?
#
# @!attribute day
#   @return [Integer]
#     the calendar day (1-31)
##
# @!attribute isbn
#   @return [String]
#   @todo
#
# @!attribute issn
#   @return [String]
#   @todo
#
# @!attribute verbatim
#   @return [String]
#     the full citation, used only for type = SourceVerbatim
#
# @!attribute verbatim_contents
#   @return [String]
#   @todo
#
# @!attribute verbatim_keywords
#   @return [String]
#   @todo
#
# @!attribute language_id
#   @return [Integer]
#     The TaxonWorks normalization of language to Language.
#
# @!attribute translator
#   @return [String]
#   @todo
#
# @!attribute year_suffix
#   @return [String]
#     Arbitrary user-provided suffix to the year.  Use is highly discouraged.
#
# @!attribute url
#   @return [String]
#   @todo
##
# @!attribute cached
#   @return [String]
#    calculated full citation, searched again in "full text"
#
# @!attribute cached_author_string
#   @return [String]
#     calculated author string
#
# @!attribute cached_nomenclature_date
#   @return [DateTime]
#     Date sensu nomenclature algorithm in TaxonWorks (see Utilities::Dates)
#
class Source < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::SharedAcrossProjects
  include Shared::Tags
  include Shared::Documentation
  include Shared::HasRoles
  include Shared::IsData
  include Shared::HasPapertrail
  include SoftValidation

  ignore_whitespace_on(:verbatim_contents)

  ALTERNATE_VALUES_FOR = [
    :address, :annote, :booktitle, :edition, :editor, :institution, :journal, :note, :organization,
    :publisher, :school, :title, :doi, :abstract, :language, :translator, :author, :url].freeze

    # @return [Boolean]
  #  When true, cached values are not built
  attr_accessor :no_year_suffix_validation

  # Keep this order for citations/topics
  has_many :citations, inverse_of: :source, dependent: :restrict_with_error
  has_many :citation_topics, through: :citations, inverse_of: :source
  has_many :topics, through: :citation_topics, inverse_of: :sources

  # !! must be below has_many :citations
  has_many :asserted_distributions, through: :citations, source: :citation_object, source_type: 'AssertedDistribution'

  has_many :project_sources, dependent: :destroy
  has_many :projects, through: :project_sources

  after_save :set_cached

  validates_presence_of :type
  validates :type, inclusion: {in: ['Source::Bibtex', 'Source::Human', 'Source::Verbatim']} # TODO: not needed

  accepts_nested_attributes_for :project_sources, reject_if: :reject_project_sources

  soft_validate(
    :sv_cached_names,
    set: :cached_names,
    fix: :sv_fix_cached_names,
    name: 'Cached names',
    description: 'Check if cached values need to be updated' )

    # Redirect type here
  # @param [String] file
  # @return [[Array, message]]
  #   TODO: return a more informative response?
  def self.batch_preview(file)
    begin
      bibliography = BibTeX::Bibliography.parse(file.read.force_encoding('UTF-8'), filter: :latex)
      sources = []
      bibliography.each do |record|
        a = Source::Bibtex.new_from_bibtex(record)
        sources.push(a)
      end
      return sources, nil
    rescue BibTeX::ParseError => e
      return [], e.message
    rescue
      raise
    end
  end

  # @param [String] file
  # @return [Array, Boolean]
  def self.batch_create(file)
    sources = []
    valid = 0
    begin
      # error_msg = []
      Source.transaction do
        bibliography = BibTeX::Bibliography.parse(file.read.force_encoding('UTF-8'), filter: :latex)
        bibliography.each do |record|
          a = Source::Bibtex.new_from_bibtex(record)
          if a.valid?
            if a.save
              valid += 1
            end
          else
            # error_msg = a.errors.messages.to_s
          end
          sources.push(a)
        end
      end
    rescue
      return false
    end
    return {records: sources, count: valid}
  end

  # @param used_on [String] a model name 
  # @return [Scope]
  #    the max 10 most recently used (1 week, could parameterize) TaxonName, as used 
  def self.used_recently(user_id, project_id, used_on = 'TaxonName')
    t = Citation.arel_table
    p = Source.arel_table

    # i is a select manager
    i = t.project(t['source_id'], t['created_at']).from(t)
      .where(t['created_at'].gt(1.weeks.ago))
      .where(t['citation_object_type'].eq(used_on))
      .where(t['created_by_id'].eq(user_id))
      .where(t['project_id'].eq(project_id))
      .order(t['created_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Source.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['source_id'].eq(p['id'])))
    ).pluck(:source_id).uniq
  end

    # @params target [String] a citable model name
  # @return [Hash] sources optimized for user selection
  def self.select_optimized(user_id, project_id, target = 'TaxonName')
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: Source.pinned_by(user_id).where(pinboard_items: {project_id: project_id}).to_a,
      recent: []
    }

    if r.empty?
      h[:recent] = Source.where(created_by_id: user_id, updated_at: 2.hours.ago..Time.now )
                       .order('created_at DESC')
                       .limit(5).order(:cached).to_a
      h[:quick] = Source.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id: project_id}).to_a
    else
        h[:recent] =
            (Source.where(created_by_id: user_id, updated_at: 2.hours.ago..Time.now )
                .order('created_at DESC')
                .limit(5).order(:cached).to_a +
            Source.where('"sources"."id" IN (?)', r.first(6) ).to_a).uniq
        h[:quick] = ( Source.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id: project_id}).to_a +
        Source.where('"sources"."id" IN (?)', r.first(4) ).to_a).uniq
    end

    h
  end

  # @return [Array]
  #    objects this source is linked to through citations
  def cited_objects
    self.citations.collect { |t| t.citation_object }
  end

  # @return [Boolean]
  def is_bibtex?
    type == 'Source::Bibtex'
  end

  # @return [Boolean]
  def is_in_project?(project_id)
    projects.where(id: project_id).any?
  end

    #  Month handling allows values from bibtex like 'may' to be handled
    # @return [Time]
  def nomenclature_date
    Utilities::Dates.nomenclature_date(day, Utilities::Dates.month_index(month), year)
  end

  # @return [Source, false]
  def clone
    s = dup
    m = "[CLONE of #{id}] "
    begin
      Source.transaction do |t|
        roles.each do |r|
          s.roles << Role.new(person: r.person, type: r.type, position: r.position )
        end

        case type
        when 'Source::Verbatim'
          s.verbatim = m + verbatim.to_s
        when 'Source::Bibtex'
          s.title = m + title.to_s
        end

        s.save!
      end
    rescue ActiveRecord::RecordInvalid
    end
    s
  end

  protected

  # Defined in subclasses
  # @return [Nil]
  def set_cached
  end

    #set in subclasses
  def get_cached
  end

    # @param [Hash] attributed
  # @return [Boolean]
  def reject_project_sources(attributed)
    return true if attributed['project_id'].blank?
    return true if ProjectSource.where(project_id: attributed['project_id'], source_id: id).any?
  end

  def sv_cached_names
    true # see validation in subclasses
  end

  def sv_fix_cached_names
    begin
      TaxonName.transaction do
        self.set_cached
      end
      true
    rescue
      false
    end
  end
end
