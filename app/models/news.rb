
# News 
#
class News < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData::Navigation
  include Shared::IsData::Metamorphosize
  include Shared::Permissions

  ADMIN_TYPES = {
    'News::Administration::BlogPost': :blog_post,
    'News::Administration::Warning': :warning,
    'News::Administration::Notice': :notice,
  }.freeze

  PROJECT_TYPES = {
    'News::Project::BlogPost': :blog_post,
    'News::Project::Instruction': :instruction,
    'News::Project::Notice': :notice,
  } 

  validates :title, presence: true
  validates :body, presence: true # uniqueness: {unique: true, scope: {:project_id}}
  
end
