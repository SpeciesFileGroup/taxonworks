# Shared code for...
#
module Shared::Citable
  extend ActiveSupport::Concern

  included do
    has_many :citations, as: :citation_object, validate: false, dependent: :destroy

    scope :without_citations, -> {includes(:citations).where(citations: {id: nil})}
  end 

  def cited?
    self.citations.any?
  end

end
