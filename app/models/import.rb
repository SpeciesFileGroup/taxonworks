#
# A class used for transient data, primarily in the development of import scripts.  
# !! Not to be use in production
#   Use import.metadata['attribute'] = foo to set an attribute.
#
class Import < ActiveRecord::Base
  store_accessor :metadata
end
