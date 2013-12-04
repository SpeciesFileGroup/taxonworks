class Tag < ActiveRecord::Base

  include Housekeeping

  belongs_to :keyword
end
