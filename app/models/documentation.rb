# A Documentation instance describes the relationship between a digital document (e.g pdf, txt file) and some data instance.
# Data types that can be document use Shared::Documentation.
#
# Documentation is to Documents as Depictions are to Images.
# !!Documentation is both singular and plural!!
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
# @!attribute page_map 
#   @return [Hash]
#     maps page numbers, key is Document page, value is Recorded page (e.g. first page of the pdf => published page 10)
#
class Documentation < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  belongs_to :documentation_object, polymorphic: true
  belongs_to :document

  # These are all handled on the database side as not-null constraints
  # They can't be validated because we use accepts_nested_attributes
  # validates_presence_of :documentation_object_type, :documentation_object_id, :document_id

  validates_presence_of :document

  accepts_nested_attributes_for :document
  accepts_nested_attributes_for :documentation_object

  def self.find_for_autocomplete(params)
    Queries::DocumentationAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
