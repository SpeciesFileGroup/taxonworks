
# News 

class News::Project < News
  include Housekeeping::Users
  include Housekeeping::Projects
  include Housekeeping::Timestamps
end
