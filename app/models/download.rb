# A Download represents an expirable file (mostly ZIP files) users can download.
#
# @!attribute name
# @return [String]
#   The name for this download (not file name).
#
# @!attribute description
# @return [String]
#   A description for this download.
#
# @!attribute filename
# @return [String]
#   The filename of this download.
#
# @!attribute type
# @return [String]
#   The type of Download, e.g. `Download::DwCArchive`.
#
# @!attribute request
# @return [String]
#   The request URI path this download was generated from. This attribute may be used for caching.
#
# @!attribute expires
# @return [Datetime]
#   The date and time this download is elegible for removal.
#
# @!attribute times_downloaded
# @return [Integer]
#   The number of times the file was downloaded.
#
# @!attribute project_id
# @return [Integer]
#   the project ID
#
# @!attribute is_public
# @return [Boolean, nil]
#     whether the Download should be shared on the API
#
# @!attribute total_records
#   @return [Integer, nil]
#     and _estimate_ of the total records (rows of data) in this Download.
#     Because Downloads can be variously create some generating might not accurate count the total
#
class Download < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  default_scope { where('expires >= ?', Time.now) }

  after_save :save_file
  after_destroy :delete_file

  validates_presence_of :name
  validates_presence_of :filename
  validates_presence_of :expires
  validates_presence_of :type

  # Gets the downloads storage path
  def self.storage_path
    STORAGE_PATH
  end

  # Used as argument for :new.
  def source_file_path=(path)
    @source_file_path = path
  end

  # @return [Pathname]
  #   Retrieves the full-path of stored file
  def file_path
    dir_path.join(filename)
  end

  def file
    File.read(file_path)
  end

  # @return [Boolean]
  #   Tells whether the download expiry date has been surpassed.
  def expired?
    expires < Time.now
  end

  # @return [Boolean]
  #   Tells whether the download is ready to be downloaded.
  def ready?
    !expired? && file_path.exist?
  end

  # Deletes associated file from storage
  def delete_file
    path = dir_path
    raise 'Download: dir_path not pointing inside storage path! Aborting deletion' unless path.to_s.start_with?(STORAGE_PATH.to_s)

    FileUtils.rm_rf(path)
  end

  private

  STORAGE_PATH = Rails.root.join(Rails.env.test? ? 'tmp' : '', "downloads#{ENV['TEST_ENV_NUMBER']}").freeze

  def dir_path
    str = id.to_s.rjust(9, '0')
    STORAGE_PATH.join(str[-str.length..-7], str[-6..-4], str[-3..-1])
  end

  def save_file
    FileUtils.mkdir_p(dir_path)
    FileUtils.cp(@source_file_path, file_path) if @source_file_path
  end
end

require_dependency 'download/basic_nomenclature'
require_dependency 'download/bibtex'
require_dependency 'download/coldp'
require_dependency 'download/dwc_archive'
require_dependency 'download/project_dump/sql'
require_dependency 'download/project_dump/tsv'
require_dependency 'download/text'
