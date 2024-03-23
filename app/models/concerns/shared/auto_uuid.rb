require_relative 'identifiers'

# If included ensures Object allways has a UUID
#
module Shared::AutoUuid

  extend ActiveSupport::Concern
  included do
    after_save :generate_uuid_if_required

    attr_accessor :uuid_identifier

    def uuid_identifier_scope
      identifiers&.where('identifiers.type like ?', 'Identifier::Global::Uuid%')&.order(:position)
    end

    def uuid_identifier
      @uuid_identifier ||= uuid_identifier_scope&.first
    end
  end

  private

  def generate_uuid_if_required
    create_object_uuid if !uuid_identifier
  end

  def create_object_uuid
    @uuid_identifier = Identifier::Global::Uuid::Auto.create!(
      by: self.created_by_id,
      project_id: self.project_id,
      identifier_object: self,
      is_generated: true
    )
  end

end
