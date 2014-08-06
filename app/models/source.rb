# A Source is the metadata that identifies the origin of some information.

# The primary purpose of Source metadata is to allow the user to find the source, that's all. 
# 
class Source < ActiveRecord::Base
  include Housekeeping::Users
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

  protected
  
  # def not_empty
  #   # a source must have content in some field
  # end

end
