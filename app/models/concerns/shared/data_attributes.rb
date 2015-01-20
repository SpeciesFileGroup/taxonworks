module Shared::DataAttributes
  extend ActiveSupport::Concern

  included do
    has_many :data_attributes, as: :attribute_subject, validate: true
    accepts_nested_attributes_for :data_attributes
  end 

  # to find if a record has attributes associated with it do  object.data_attributes.any?

  def keyword_value_hash
    self.data_attributes.inject({}) do |hsh, a|   
      if a.class == ImportAttribute
        hsh.merge!(a.import_predicate => a.value)
      else # there are only two
        hsh.merge!(a.predicate.name => a.value)
      end
    end 
  end

end
