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

  accepts_nested_attributes_for :documentation

  #region class methods

  def self.find_for_autocomplete(params)
    Queries::DocumentAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

  #endregion

end
