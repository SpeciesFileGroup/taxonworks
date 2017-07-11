class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
    # def []=(index, object)
    #   super(index, object)
    # end
end
