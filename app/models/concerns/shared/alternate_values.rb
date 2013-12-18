module Shared::AlternateValues
  extend ActiveSupport::Concern

  included do
    has_many :alternate_values, as: :alternate_object
  end

  def has_alternates?
    self.alternate_values.count > 0
  end

end