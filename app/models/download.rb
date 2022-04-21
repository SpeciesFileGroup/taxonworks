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

  def build_async(record_scope, predicate_extension_params: {})
    ::DwcaCreateDownloadJob.perform_later(self, core_scope: record_scope.to_sql, predicate_extension_params: predicate_extension_params)
  end

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
    raise "Download: dir_path not pointing inside storage path! Aborting deletion" unless path.to_s.start_with?(STORAGE_PATH.to_s)

    FileUtils.rm_rf(path)
  end

  def api_buildable?
    false
  end

  private

  STORAGE_PATH = Rails.root.join(Rails.env.test? ? 'tmp' : '', "downloads#{ENV['TEST_ENV_NUMBER']}").freeze

  # TODO: check performance on 50-100mb files
  def set_sha2
    if @source_file_path
      s = ::Digest::SHA2.new
      File.open(@source_file_path) do |f|
        while chunk = f.read(256) # only load 256 bytes at a time
          s << chunk
        end
      end
      self.update_column(:sha2, s.hexdigest)
    end
  end

  def dir_path
    str = id.to_s.rjust(9, '0')
    STORAGE_PATH.join(str[-str.length..-7], str[-6..-4], str[-3..-1])
  end

  # This is the only method to move a temporary file
  # to its location on the file server.
  #
  # ActiveJob generating files trigger this method
  # by .updating the filename attribute.
  def save_file
    FileUtils.mkdir_p(dir_path)
    if @source_file_path
      FileUtils.cp(@source_file_path, file_path)
      set_sha2
    end
  end
end

require_dependency 'download/basic_nomenclature'
require_dependency 'download/bibtex'
require_dependency 'download/coldp'
require_dependency 'download/dwc_archive'
require_dependency 'download/dwc_archive/complete'
require_dependency 'download/sql_project_dump'
require_dependency 'download/text'
