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
#     size of the document in K
#
# @!attribute document_file_updated_at
#   @return [Timestamp]
#     last time this document was updated
#
# @!attribute page_map
#   @return [Hash]
#      a map of PDF page to printed page #, pages index starts at 1
#      behaviour:
#         if no integer exists for a PDF page then page is assumed to be the page # of the PDF (almost never the real case)
#         if an integer is provided it points to the page(s) represented in print
#         e.g.:
#            { "1": "300",
#              "2": ["301", "302", "xi"]
#            }
#         mapping can be many to many:
#            { "1": ["300", "301"]
#              "2": ["301"]
#            } ... printed page 301 is on pdf pages 1,2; page 1 contains printed pages 300, and part of 301
#
class Document < ApplicationRecord
  include Housekeeping
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData
  include SoftValidation

  attr_accessor :initialize_start_page

  before_destroy :check_for_documentation, prepend: true

  has_many :documentation, dependent: :destroy, inverse_of: :document

  has_many :sources, through: :documentation, source_type: 'Source', source: 'documentation_object'

  has_attached_file :document_file,
    filename_cleaner:  Utilities::CleanseFilename

  validates_attachment_content_type :document_file, content_type: ['application/octet-stream', 'application/pdf', 'text/plain', 'text/xml']
  validates_attachment_presence :document_file
  validates_attachment_size :document_file, greater_than: 1.bytes

  accepts_nested_attributes_for :documentation, allow_destroy: true, reject_if: :reject_documentation

  before_save :set_pdf_metadata, if: -> {
    ActiveSupport::Deprecation.silence do
      changed_attributes.include?('document_file_file_size') &&
        document_file_content_type =~ /pdf/
    end
  }

  def set_pages_by_start(sp = 1)
    write_attribute(:page_map, get_page_map(sp))
  end

  def get_page_map(sp = 1)
    m = {}
    if page_total && sp
      (0..(page_total - 1)).each do |p|
        m[p + 1] = (p + sp.to_i).to_s
      end
    end
    m
  end

  # @return [Array]
  def pdf_page_for(printed_page)
    p = []
    page_map.each do |pdf_page, v|
      p.push(pdf_page) if printed_page.to_s == v || v.include?(printed_page.to_s)
    end
    p
  end

  def set_page_map_page(index, page)
    return false if index.kind_of?(Array) && page.kind_of?(Array)
    return false if !index.kind_of?(Array) && (index.to_i > page_total)

    p = page_map

    [index].flatten.map(&:to_s).each do |i|
      if page.kind_of?(Array)
        p[i] = page.map(&:to_s)
      else
        p[i] = page.to_s
      end
    end

    update_attribute(:page_map, p)
  end

  def initialize_start_page=(value)
    write_attribute(:page_map, get_page_map(value))
    @initialize_start_page = value 
  end

  def pdftotext
    `pdftotext -layout #{document_file.path} -`  
  end

  protected

  def check_for_documentation
    if documentation.count > 1 
      errors.add(:base, 'document is used in more than one place, remove documentation first')
      throw :abort 
    end
  end

  def set_pdf_metadata
    begin
      File.open(document_file.staged_path, 'rb') do |io|
        reader = PDF::Reader.new(io)
        write_attribute(:page_total, reader.page_count)
      end
    rescue PDF::Reader::MalformedPDFError
      errors.add(:base, 'pdf is malformed')
    end
    set_pages_by_start(initialize_start_page) if initialize_start_page
  end

  def reject_documentation(attributed)
    attributed['type'].blank? || attributed['documentation_object'].blank? && (attributed['documentation_object_id'].blank? && attributed['documentation_object_type'].blank?)
  end
end
