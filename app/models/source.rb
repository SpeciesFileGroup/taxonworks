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
#     An exception to the 1:1 modelling.  We retain for Rails STI usage. Either Source::Verbatim or Source::Bibtex.  The former can only consist of a single field (the full citation as a string).  The latter is a Bibtex model.  See "bibtex_type" for the bibtex attribute "type".
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
class Source < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::HasRoles
  include Shared::Identifiable
  include Shared::Notable
  include Shared::SharedAcrossProjects
  include Shared::Taggable
  include Shared::IsData

  has_paper_trail

  # Class constants
  ALTERNATE_VALUES_FOR = [:address, :annote, :booktitle, :edition, :editor, :institution, :journal, :note, :organization,
                          :publisher, :school, :title, :doi, :abstract, :language, :translator, :author, :url]

#  has_many :asserted_distributions, inverse_of: :source
  has_many :citations, inverse_of: :source, dependent: :restrict_with_error 
  has_many :projects, through: :project_sources
  has_many :project_sources, dependent: :destroy

  before_save :set_cached

  validates_presence_of :type

  accepts_nested_attributes_for :project_sources, reject_if: proc { |attributes| attributes['project_id'].blank? }

  def cited_objects
    self.citations.collect { |t| t.citation_object }
  end

  def self.find_for_autocomplete(params)
    Queries::SourceAutocompleteQuery.new(params[:term]).all
  end

  # Create a new Source instance from a full text citatation.  By default
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
  def self.new_from_citation(citation: nil, resolve: true)
    return false if citation.length < 6
    bibtex_string = Ref2bibtex.get(citation) if resolve
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

  def self.new_from_doi(doi: nil)
    return false unless doi
    bibtex_string = Ref2bibtex.get_bibtex(doi)
    if bibtex_string
      b = BibTeX.parse(bibtex_string).first
      return Source::Bibtex.new_from_bibtex(b)
    end
    false
  end

  def self.batch_preview(file: nil, ** args)
    bibliography = BibTeX.parse(file.read.force_encoding('UTF-8'))
    @sources     = []
    bibliography.each do |record|
      a = Source::Bibtex.new_from_bibtex(record)
      # v = a.valid?
      a.soft_validate()
      @sources.push(a)
    end
    @sources
  end

  def self.batch_create(file: nil, ** args)
    @sources = []
    @valid   = 0
    begin
      error_msg = []
      Source.transaction do
        bibliography = BibTeX.parse(file.read.force_encoding('UTF-8'))
        bibliography.each do |record|
          a = Source::Bibtex.new_from_bibtex(record)
          if a.valid?
            if a.save
              @valid += 1
            end
            a.soft_validate()
          else
            error_msg = a.errors.messages.to_s
          end
          @sources.push(a)
        end
      end
    rescue
      return false
    end
    {records: @sources, count: @valid}
  end

  # TODO: remove and use code in  Shared::IsData::Levenshtein
  def nearest_by_levenshtein(compared_string: nil, column: 'cached', limit: 10)
    return Source.none if compared_string.nil?
    order_str = Source.send(:sanitize_sql_for_conditions, ["levenshtein(sources.#{column}, ?)", compared_string])
    Source.where('id <> ?', self.to_param).
      order(order_str).
      limit(limit)
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

  def is_bibtex?
    type == 'Source::Bibtex'
  end

  protected

  def set_cached
    # in subclasses
  end

end
