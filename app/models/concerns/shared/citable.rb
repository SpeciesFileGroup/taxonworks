module Shared::Citable
  extend ActiveSupport::Concern

  included do
    has_many :citations, as: :citation_object, validate: false
  end 

  def cited?
    self.citations.any?
  end

end
