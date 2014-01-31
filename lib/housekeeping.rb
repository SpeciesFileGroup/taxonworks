# Concerns for models that are project specific and that have creator/updators
module Housekeeping 

  extend ActiveSupport::Concern
  included do
    include Users
    include Projects 
   #  before_validation :set_housekeeping_for_polymorphic_relationships, if: :has_polymorphic_relationship?
  end

  def has_polymorphic_relationship?
    self.class.reflect_on_all_associations(:belongs_to).select{|a| a.polymorphic?}.count > 0
  end

  def set_housekeeping_for_polymorphic_relationships
    self.class.reflect_on_all_associations(:belongs_to).select{|a| a.polymorphic?}.each do |rel| 
      if i = self.send(rel.name)
        if !i.created_by_id.blank? 
        end
      end
      debugger
      foo = 1
    end
  end

end
