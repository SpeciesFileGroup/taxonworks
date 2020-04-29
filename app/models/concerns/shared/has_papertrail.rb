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

  def attribute_updater(attribute)
    versions&.select{|v| !v.reify.send(attribute).nil?}&.collect{|o| o.reify.updated_by_id}&.compact&.last
  end

  def attribute_updated(attribute)
    versions&.select{|v| !v.reify.send(attribute).nil?}&.collect{|o| o.reify.updated_at}&.compact&.last
  end




end
