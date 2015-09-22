# A Source is the metadata that identifies the origin of some information.
#
# The primary purpose of Source metadata is to allow the user to find the source, that's all. 
# 
# @!attribute serial_id
#   @return [Integer]
#   @todo
#
# @!attribute address
#   @return [String]
#   @todo
#
# @!attribute annote
#   @return [String]
#   @todo
#
# @!attribute booktitle
#   @return [String]
#   @todo
#
# @!attribute chapter
#   @return [String]
#   @todo
#
# @!attribute crossref
#   @return [String]
#   @todo
#
# @!attribute edition
#   @return [String]
#   @todo
#
# @!attribute editor
#   @return [String]
#   @todo
#
# @!attribute howpublished
#   @return [String]
#   @todo
#
# @!attribute institution
#   @return [String]
#   @todo
#
# @!attribute journal
#   @return [String]
#   @todo
#
# @!attribute key
#   @return [String]
#   @todo
#
# @!attribute month
#   @return [String]
#   @todo
#
# @!attribute note
#   @return [String]
#   @todo
#
# @!attribute number
#   @return [String]
#   @todo
#
# @!attribute organization
#   @return [String]
#   @todo
#
# @!attribute pages
#   @return [String]
#   @todo
#
# @!attribute publisher
#   @return [String]
#   @todo
#
# @!attribute school
#   @return [String]
#   @todo
#
# @!attribute series
#   @return [String]
#   @todo
#
# @!attribute title
#   @return [String]
#   @todo
#
# @!attribute type
#   @return [String]
#   @todo
#
# @!attribute volume
#   @return [String]
#   @todo
#
# @!attribute doi
#   @return [String]
#   @todo
#
# @!attribute abstract
#   @return [String]
#   @todo
#
# @!attribute copyright
#   @return [String]
#   @todo
#
# @!attribute language
#   @return [String]
#   @todo
#
# @!attribute stated_year
#   @return [String]
#   @todo
#
# @!attribute verbatim
#   @return [String]
#   @todo
#
# @!attribute bibtex_type
#   @return [String]
#   @todo
#
# @!attribute day
#   @return [Integer]
#   @todo
#
# @!attribute year
#   @return [Integer]
#   @todo
#
# @!attribute isbn
#   @return [String]
#   @todo
#
# @!attribute issn
#   @return [String]
#   @todo
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
#   @todo
#
# @!attribute translator
#   @return [String]
#   @todo
#
# @!attribute year_suffix
#   @return [String]
#   @todo
#
# @!attribute url
#   @return [String]
#   @todo
#
# @!attribute author
#   @return [String]
#   @todo
#
# @!attribute cached
#   @return [String]
#   @todo
#
# @!attribute cached_author_string
#   @return [String]
#   @todo
#
# @!attribute cached_nomenclature_date
#   @return [DateTime]
#   @todo
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

  has_many :asserted_distributions, inverse_of: :source
  has_many :citations, inverse_of: :source, dependent: :destroy
  has_many :projects, through: :project_sources
  has_many :project_sources, dependent: :destroy

  before_save :set_cached

  validates_presence_of :type

  def cited_objects
    self.citations.collect { |t| t.citation_object }
  end

  def self.find_for_autocomplete(params)
    where('cached LIKE ?', "%#{params[:term]}%")
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
      b            = bibliography.first
      return Source::Bibtex.new_from_bibtex(b)
    else
      return Source::Verbatim.new(verbatim: citation)
    end
  end

  def self.new_from_doi(doi: nil)
    return false if !doi
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
    @valid = 0
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
