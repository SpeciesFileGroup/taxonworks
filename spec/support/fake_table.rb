# There is a dummy table used only in testing called 'test_classes'.
# It contains the following attributes:
#
#   id
#   created_by_id
#   updated_by_id
#   project_id
#   string
#   integer
#   boolean
#   text
#
# Example use:
#
#    class WithUser < ApplicationRecord
#      include SomeConcern 
#      include FakeTable 
#    end
#
module FakeTable
  extend ActiveSupport::Concern
  included do 
    self.table_name = 'test_classes' 
  end
end
