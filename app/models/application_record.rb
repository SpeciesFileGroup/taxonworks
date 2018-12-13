class ApplicationRecord < ActiveRecord::Base

  # Required here due to the eager load before config/routes.rb
  include NilifyBlanks

  self.abstract_class = true

    # def []=(index, object)
    #   super(index, object)
    # end

end
