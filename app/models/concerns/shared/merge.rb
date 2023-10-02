

module Shared::Merge


  extend ActiveSupport::Concern

  included do
  end

  def merge(object_to_remove)
    o = object_to_remove

    # All related non-annotation objects, by default
    object.class.transaction do


      begin
        ApplicationEnumeration.data_models.each do |m|


        end
      rescue ActiveRecord::RecordInvalid
      end

    end




  end

end
