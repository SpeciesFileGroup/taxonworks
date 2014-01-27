# This is a 1:1 represntation of ISO 639-2.  
# It is built on initialization with a rake task, and not further touched.
class Language < ActiveRecord::Base

  include Housekeeping::Users

  validates_presence_of :english_name, :alpha_3_bibliographic
end
