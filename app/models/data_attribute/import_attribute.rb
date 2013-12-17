class DataAttribute::ImportAttribute < DataAttribute
  include Housekeeping::Users
  validates_presence_of :import_predicate
end
