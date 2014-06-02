# Concerns for models that have creator/updaters.
module Housekeeping 
  extend ActiveSupport::Concern
  included do
    include Users
    include Projects 
    include Timestamps
  end

  def has_polymorphic_relationship?
    self.class.reflect_on_all_associations(:belongs_to).select{|a| a.polymorphic?}.count > 0
  end

end
