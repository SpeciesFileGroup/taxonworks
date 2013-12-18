module Shared::DataAttributes
  extend ActiveSupport::Concern

  included do
    has_many :data_attributes, as: :attribute_subject
  end 

  def has_data_attributes?
    self.data_attributes.count > 0
  end

end
