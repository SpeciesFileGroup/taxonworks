# A Download represents an expirable file (mostly ZIP files) users can download.
#
# @!attribute name
#   @return [String]
#   The name for this download (not file name).
#
# @!attribute description
#   @return [String]
#   A description for this download.
#
# @!attribute filename
#   @return [String]
#   The filename of this download.
#
# @!attribute request
#   @return [String]
#   The request URI path this download was generated from. This attribute may be used for caching.
#
# @!attribute expires
#   @return [Datetime]
#   The date and time this download is elegible for removal.
#
# @!attribute times_downloaded
#   @return [Integer]
#   The number of times the file was downloaded.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Download < ApplicationRecord
  include Housekeeping

  attribute :file_path # Virtual attribute

  before_save :save_file
  after_save :set_file_path
  after_find :set_file_path

  validates_presence_of :name
  validates_presence_of :filename
  validates_presence_of :expires


  def save_file
    FileUtils.cp(file_path, Rails.root.join('downloads', filename))
  end

  def set_file_path
    write_attribute(:file_path,  "#{id}/#{filename}")
  end

  def file
    File.read(file_path)    
  end
end
