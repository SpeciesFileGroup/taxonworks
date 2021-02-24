# A Documentation instance describes the relationship between a digital document (e.g pdf, txt file) and some data instance.
# Data types that can be document use Shared::Documentation.
#
# Documentation is to Documents as Depictions are to Images.
# !!`Documentation` is both singular and plural!!
#
# @!attribute documentation_object_id
#   @return [String]
#    the id of the documented object
#
# @!attribute documentation_object_type
#   @return [String]
#    the type of the documented object
#
# @!attribute document_id
#   @return [String]
#     the id of the Document
#
# @!attribute position 
#   @return [Integer]
#     for acts as list, scopes to document
#
class Documentation < ApplicationRecord

  acts_as_list scope: [:project_id, :documentation_object_id, :documentation_object_type]

  include Housekeeping
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData
  include SoftValidation
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:documentation_object)

  # These are all handled on the database side as not-null constraints
  # They can't be validated because we use accepts_nested_attributes
  # validates_presence_of :documentation_object_type, :documentation_object_id, :document_id
  # TODO: above is probably bs
  # 
  # We catch invalid statements with this around:
  around_save :catch_statement_invalid

  belongs_to :documentation_object, polymorphic: true
  belongs_to :document, inverse_of: :documentation

  after_destroy :destroy_document_if_last

  validates_presence_of :document

  accepts_nested_attributes_for :document
  accepts_nested_attributes_for :documentation_object

  protected

  def destroy_document_if_last
    document.destroy if Documentation.where(document: document).count == 0
  end

  def catch_statement_invalid
    begin
      yield # calls :after_save callback
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.class.name == 'PG::NotNullViolation'
        errors.add(:base, 'a required field was not provided')
      else
        raise
      end
    end
  end

end
