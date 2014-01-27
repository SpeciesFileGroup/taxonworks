# Concerns for models that are project specific and that have creator/updators
module Housekeeping 
  extend ActiveSupport::Concern
  included do
    include Users
    include Projects  
  end
end
