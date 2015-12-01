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

  validates_attachment_content_type :document_file, content_type: 'document/pdf'
  validates_attachment_presence :document_file
  validates_attachment_size :document_file, greater_than: 1.kilobytes

end
