class Source < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::HasRoles
  include Shared::Notable
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Taggable

  has_many :citations, inverse_of: :source
  has_many :cited_objects, through: :citations, source: :citation_object # not ordered

  #validate :not_empty

  protected
  
  # def not_empty
  #   # a source must have content in some field
  # end

end
