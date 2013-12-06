module Shared::Notable
  extend ActiveSupport::Concern

  included do
    has_many :notes
  end 

  module ClassMethods
  end


end
