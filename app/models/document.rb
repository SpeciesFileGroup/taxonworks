# A Document is digital file that has text inhering within it.  Handled formats are pdfs and txt at present.
#
# Documents are to Documentation as Images are to Depictions.
#
# @!attribute document_file_file_name
#   @return [String]
#   the name of the file as uploaded by the user.
#
# @!attribute document_file_content_type 
#   @return [String]
#    the content type (mime) 
#
# @!attribute document_file_file_size 
#   @return [Integer]
#     size fo the document in K 
#
# @!attribute document_file_updated_at
#   @return [Timestamp]
#     last time this document was updated 
#
class Document < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  has_many :documentation

  has_attached_file :document_file,
                    filename_cleaner:  Utilities::CleanseFilename

  validates_attachment_content_type :document_file, content_type: ['application/pdf', 'text/plain', 'text/xml']
  validates_attachment_presence :document_file
  validates_attachment_size :document_file, greater_than: 1.bytes

  accepts_nested_attributes_for :documentation, allow_destroy: true, reject_if: :reject_documentation

  def reject_documentation(attributed)
    attributed['type'].blank? || attributed['documentation_object'].blank? && (attributed['documentation_object_id'].blank? && attributed['documentation_object_type'].blank?)
  end

  def self.find_for_autocomplete(params)
    Queries::DocumentAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
