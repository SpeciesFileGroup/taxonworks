# Shared code for documenting objects, i.e. linking a document to a data instance.
#
module Shared::Documentation

  extend ActiveSupport::Concern

  included do
   # attr_accessor :image_array

    ::Documentation.related_foreign_keys.push self.name.foreign_key

    # !! destroying the last documentation for a document will destroy the document as well !!
    has_many :documentation, validate: true, as: :documentation_object, dependent: :destroy, inverse_of: :documentation_object
    has_many :documents, validate: true, through: :documentation

    accepts_nested_attributes_for :documentation, allow_destroy: true, reject_if: :reject_documentation
    accepts_nested_attributes_for :documents, allow_destroy: true, reject_if: :reject_documents
  end

  def documented?
    documentation.any?
  end

  def document_array=(documents)
    self.documentation_attributes = documents.collect{|i, file| { document_attributes: {document_file: file}}}
  end

  protected

  # Not tested!
  def reject_documentation(attributed)
    attributed['document_attributes'].blank? ||  attributed['document_attributes']['document_file'].blank?
  end

  def reject_documents(attributed)
    attributed['document_file'].blank? 
  end

end
