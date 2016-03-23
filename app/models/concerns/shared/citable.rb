# Shared code for Citations
#
module Shared::Citable
  extend ActiveSupport::Concern

  included do
    has_many :citations, as: :citation_object, validate: false, dependent: :destroy
    has_many :sources, through: :citations

    has_one :origin_citation, -> {where is_original: true}, as: :citation_object, class_name: 'Citation'
    has_one :source, through: :origin_citation
  end 
  
  def cited?
    self.citations.any?
  end

end
