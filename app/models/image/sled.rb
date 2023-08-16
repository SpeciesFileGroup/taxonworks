# SledImage related code
module ::Image::Sled
  extend ActiveSupport::Concern

  included do
    related_class = self.name
    klass = related_class.tableize.singularize.safe_constantize

    has_one :sled_image
  end


  module ClassMethods

  end

end
