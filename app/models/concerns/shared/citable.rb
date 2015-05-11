module Shared::Citable
  extend ActiveSupport::Concern

  included do
    has_many :citations, as: :citation_object, validate: false, dependent: :destroy
  end 

  def cited?
    self.citations.any?
  end

end
