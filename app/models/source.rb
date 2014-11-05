# A Source is the metadata that identifies the origin of some information.

# The primary purpose of Source metadata is to allow the user to find the source, that's all. 
# 
class Source < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 
  include Shared::SharedAcrossProjects
  include Shared::Identifiable
  include Shared::HasRoles
  include Shared::Notable
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Taggable

  has_many :citations, inverse_of: :source, dependent: :destroy
  has_many :cited_objects, through: :citations, source_type: 'CitedObject'
  has_many :projects, through: :project_sources
  has_many :project_sources, dependent: :destroy

  #validate :not_empty

  def self.find_for_autocomplete(params)
    where('cached LIKE ?', "%#{params[:term]}%") 
  end


  # TODO: Test
  # Create a new instance from a full text citatation.  By default 
  # try to resolve the citation against Crossref, use the returned
  # bibtex to populate the object if it successfully resolves. 
  # @return[Source::Bibtex.new()] 
  # returns false  if citation length < 4
  def self.new_from_citation(citation: nil, resolve: true)
    if citation.length > 3
      if resolve
        if bibtext_string = Ref2bibtex.get(citation)
          return Source::Bibtex.new_from_bibtex(bibtex_string)
        end
      end
      return Source::Verbatim.new(verbatim: citation )
    end
  end

  
end
