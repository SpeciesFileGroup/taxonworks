# Shared code for models using PaperTrail
#
module Shared::HasPapertrail

  extend ActiveSupport::Concern 
  included do
    has_paper_trail on: [:update], ignore: [:created_at, :updated_at]

    before_save(on: :update) do
      PaperTrail.request.whodunnit = Current.user_id || $user_id
    end
  end

end
