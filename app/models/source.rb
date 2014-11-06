# A Source is the metadata that identifies the origin of some information.

# The primary purpose of Source metadata is to allow the user to find the source, that's all. 
# 
class Source < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData 
  include Shared::SharedAcrossProjects
  include Shared::Identifiable
  include Shared::HasRoles
  include Shared::Notable
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Taggable

  has_many :citations, inverse_of: :source, dependent: :destroy
  has_many :projects, through: :project_sources
  has_many :project_sources, dependent: :destroy

  after_validation :set_cached_values

  def cited_objects
    self.citations.collect{|t| t.citation_object}
  end

  def self.find_for_autocomplete(params)
    where('cached LIKE ?', "%#{params[:term]}%") 
  end

  # Create a new Source instance from a full text citatation.  By default 
  # try to resolve the citation against Crossref, use the returned
  # bibtex to populate the object if it successfully resolves. 
  #
  # @param citation [String] the full text of the citation to convert
  # @param resolve [Boolean] whether to resolve against CrossRef, if false then creates a verbatim instance 
  # @return [Source::BibTex.new] a new instance 
  # @return [false] a new instance 
  def self.new_from_citation(citation: nil, resolve: true)
    return false if citation.length < 6
    bibtex_string = Ref2bibtex.get(citation) if resolve
    if bibtex_string 
      b = BibTeX.parse(bibtex_string).first
      return Source::Bibtex.new_from_bibtex(b)
    else
      return Source::Verbatim.new(verbatim: citation )
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
    bibliography = BibTeX.open(file)
    @sources = []
    bibliography.each do |record|
      @sources.push(Source::Bibtex.new_from_bibtex(record))
    end
    @sources
  end
  
  def nearest_by_levenshtein(compared_string: nil, column: 'cached', limit: 10)
    return Source.none if compared_string.nil?
    order_str = Source.send(:sanitize_sql_for_conditions, ["levenshtein(sources.#{column}, ?)", compared_string])
    Source.where('id <> ?', self.to_param).
      order(order_str).
      limit(limit)
end

  protected

  def set_cached_values
    # in subclasses
  end

end
