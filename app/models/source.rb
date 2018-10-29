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
#   @todo
#
# @!attribute day
#   @return [Integer]
#   @todo
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

  ALTERNATE_VALUES_FOR = [:address, :annote, :booktitle, :edition, :editor, :institution, :journal, :note, :organization,
                          :publisher, :school, :title, :doi, :abstract, :language, :translator, :author, :url].freeze

  has_many :citations, inverse_of: :source, dependent: :restrict_with_error
  has_many :asserted_distributions, through: :citations, source: :citation_object, source_type: 'AssertedDistribution'
  has_many :project_sources, dependent: :destroy
  has_many :projects, through: :project_sources

  after_save :set_cached

  validates_presence_of :type
  validates :type, inclusion: {in: ['Source::Bibtex', 'Source::Human', 'Source::Verbatim']}

  accepts_nested_attributes_for :project_sources, reject_if: :reject_project_sources

  # Create a new Source instance from a full text citatation.  By default,
  # try to detect and clean up a DOI, then
  # try to resolve the citation against Crossref, use the returned
  # bibtex to populate the object if it successfully resolves.
  #
  # Once created followup with .create_related_people_and_roles to create related people.
  #
  # @param citation [String] the full text of the citation to convert
  # @param resolve [Boolean] whether to resolve against CrossRef, if false then creates a verbatim instance
  # @return [Source::BibTex.new] a new instance
  # @return [Source::Verbatim.new] a new instance
  # @return [false]
  # Four possible paths:
  # 1)  citation.
  # 2)  citation which includes a doi.
  # 3)  naked doi, e.g., '10.3897/zookeys.20.205'.
  # 4)  doi with preamble, e.g., 'http://dx.doi.org/10.3897/zookeys.20.205' or
  #                              'https://doi.org/10.3897/zookeys.20.205'.
  def self.new_from_citation(citation: nil, resolve: true)
    return false if citation.length < 6
    path = 1  # assumes straight citation text

    doi = Identifier::Global::Doi.new(identifier: citation)
    if doi.valid?
      citation = Identifier::Global::Doi.preface_doi(doi.identifier)
      path = 3
    end

    case path
      when 1, 2
        bibtex_string = Ref2bibtex.get(citation) if resolve
      when 3, 4
        bibtex_string = Ref2bibtex.get_bibtex(citation)
      else
    end
    # check string encoding, if not UTF-8, check if compatible with UTF-8,
    # if so convert to UTF-8 and parse with latex, else use type verbatim
    if bibtex_string
      unless bibtex_string.encoding == Encoding::UTF_8
        x = 'test'.encode(Encoding::UTF_8)
        if Encoding.compatible?(x, bibtex_string)
          bibtex_string.force_encoding(Encoding::UTF_8)
        else
          return Source::Verbatim.new(verbatim: citation)
        end
      end

      bibliography = BibTeX.parse(bibtex_string).convert(:latex)
      b = bibliography.first
      return Source::Bibtex.new_from_bibtex(b)
    else
      return Source::Verbatim.new(verbatim: citation)
    end
  end

  # @param [String] doi
  # @return [Source::Bibtex, Boolean]
  def self.new_from_doi(doi: nil)
    return false unless doi
    bibtex_string = Ref2bibtex.get_bibtex(doi)
    if bibtex_string
      b = BibTeX.parse(bibtex_string).first
      return Source::Bibtex.new_from_bibtex(b)
    end
    false
  end

  # Redirect type here
  # @param [String] file
  # @return [[Array, message]]
  #   TODO: return a more informative response?
  def self.batch_preview(file)
    begin
      bibliography = BibTeX.parse(file.read.force_encoding('UTF-8'), filter: :latex)
      sources = []
      bibliography.each do |record|
        a = Source::Bibtex.new_from_bibtex(record)
        a.soft_validate() # why?
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
        bibliography = BibTeX.parse(file.read.force_encoding('UTF-8'), filter: :latex)
        bibliography.each do |record|
          a = Source::Bibtex.new_from_bibtex(record)
          if a.valid?
            if a.save
              valid += 1
            end
            a.soft_validate()
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

  protected

  # Defined in subclasses
  # @return [Nil]
  def set_cached
  end

  # @param [Hash] attributed
  # @return [Boolean]
  def reject_project_sources(attributed)
    return true if attributed['project_id'].blank?
    return true if ProjectSource.where(project_id: attributed['project_id'], source_id: id).any?
  end

end
