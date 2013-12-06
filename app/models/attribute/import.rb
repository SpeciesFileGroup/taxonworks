class Attribute::Import < Attribute 
  include Housekeeping::Users
  validates_presence_of :import_predicate
end
