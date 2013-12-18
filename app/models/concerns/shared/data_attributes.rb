module Shared::DataAttributes
  extend ActiveSupport::Concern

  included do
    has_many :data_attributes, as: :attribute_subject
  end 

  def has_data_attributes?
    self.data_attributes.count > 0
  end

  def keyword_value_hash
    self.data_attributes.inject({}) do |hsh, a| 
      if a.class == DataAttribute::ImportAttribute
        hsh.merge!(a.import_predicate => a.value)
      else # there are only two
        hsh.merge!(a.predicate.name => a.value)
      end
    end 
  end

end
