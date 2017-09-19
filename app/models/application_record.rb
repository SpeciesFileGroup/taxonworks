class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  require 'application_enumeration'

    # def []=(index, object)
    #   super(index, object)
    # end
end
