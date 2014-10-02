module Shared::IsData 
  extend ActiveSupport::Concern

  included do
     include Pinnable 
  end


end
