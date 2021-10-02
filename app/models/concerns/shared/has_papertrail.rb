# Shared code for models using PaperTrail
#
module Shared::HasPapertrail
  extend ActiveSupport::Concern
  included do
    has_paper_trail on: [:update], ignore: [:created_at, :updated_at]

    before_update do
      PaperTrail.request.whodunnit = Current.user_id
    end
  end

  # @return [:updated_by_id, attribute, nil]
  def attribute_updater(attribute)
    versions.reverse.each do |v|
      r = v.reify
      unless r.nil?
        if a = r.send(attribute)
          return r.updated_by_id
        end
      end
    end
    nil
  end

  # @return [:updated_by_id, attribute, nil]
  def attribute_updated(attribute)
     versions.reverse.each do |v|
      r = v.reify
      unless r.nil?
        if a = r.send(attribute)
          return r.updated_at
        end
      end
    end
   nil
  end

end
