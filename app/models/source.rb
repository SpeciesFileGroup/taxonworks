class Source < ActiveRecord::Base
  include Shared::Identifiable 
  include Shared::HasRoles 

  #validate :not_empty

  protected
# def not_empty
#   # a source must have content in some field
# end

end
