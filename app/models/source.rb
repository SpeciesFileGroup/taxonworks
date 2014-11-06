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
    if citation.length > 3
      bibtex_string = Ref2bibtex.get(citation) if resolve
      if bibtex_string 
        b = BibTeX.parse(bibtex_string).first
        return Source::Bibtex.new_from_bibtex(b)
      end
      return Source::Verbatim.new(verbatim: citation )
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

end
