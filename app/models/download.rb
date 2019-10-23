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

  after_create :save_file
  after_destroy :delete_file

  validates_presence_of :name
  validates_presence_of :filename
  validates_presence_of :expires


  # Gets the downloads storage path
  def self.storage_path
    STORAGE_PATH
  end

  # Used as argument for :new.
  def source_file_path=(path)
    @source_file_path = path
  end

  # Retrieves the full-path of stored file
  def file_path
    STORAGE_PATH.join(id.to_s, filename)
  end

  def file
    File.read(file_path)
  end

  private

  STORAGE_PATH = Rails.root.join(Rails.env.test? ? 'tmp' : '', 'downloads').freeze

  def dir_path
    STORAGE_PATH.join(id.to_s)
  end

  def save_file
    FileUtils.mkdir_p(dir_path)
    FileUtils.cp(@source_file_path, file_path)
  end

  def delete_file
    path = dir_path
    raise "Download: dir_path not pointing inside storage path! Aborting deletion" unless path.to_s.start_with?(STORAGE_PATH.to_s)

    FileUtils.rm_rf(path)
  end
end
