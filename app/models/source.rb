# A Source is the metadata that identifies the origin of some information.

# The primary purpose of Source metadata is to allow the user to find the source, that's all. 
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

  after_validation :set_cached

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
      @sources.push(a)
    end
    @sources
  end

  def self.batch_create(file: nil, ** args)
    sources = []
    begin
      Source.transaction do
        bibliography = BibTeX.parse(file.read.force_encoding('UTF-8'))
        bibliography.each do |record|
          a = Source::Bibtex.new_from_bibtex(record)
          a.save!
          sources.push(a)
        end
      end
    rescue
      raise
    end
    sources
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

  protected

  def set_cached
    # in subclasses
  end

end
