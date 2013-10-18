class Citation < ActiveRecord::Base

  belongs_to :citation_object, polymorphic: :true
  belongs_to :source

end
