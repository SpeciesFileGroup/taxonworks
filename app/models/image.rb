# Image - class the represents an image stored in the filesystem.
#
# This class relies on the paperclip gem and the ImageMagik app to link, store and manipulate images.
#
# @!attribute id
#   The ActiveRecord id, which is used by paperclip to organize the images in the filesystem.
#
# @!attribute user_file_name The name of the file as uploaded by the user.
# @!attribute height
# @!attribute width
#
# @!group attributes added by paperclip
# @!attribute image_file_fingerprint MD5 for the image file
# @!attribute image_file_file_name The filename after processing to remove special characters.
# @!attribute image_file_content_type The MIME (must be image) and file type (e.g. image/png).
# @!attribute image_file_file_size
# @!attribute image_file_updated_at
# @!endgroup
#
class Image < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include SoftValidation

  #constants
  MISSING_IMAGE_PATH = '/public/images/missing.jpg'

  before_save :extract_tw_attributes

  has_attached_file :image_file,
       :styles => {:medium => '300x300>', :thumb => '100x100>'},
       :default_url => MISSING_IMAGE_PATH,
       :filename_cleaner => CleanseFilename
       #:restricted_characters => /[^A-Za-z0-9\.]/,
  validates_attachment_content_type :image_file, :content_type => /\Aimage\/.*\Z/
  validates_attachment_presence :image_file
  validates_attachment_size :image_file, greater_than: 1.kilobytes

  soft_validate(:sv_duplicate_image?)

  def has_duplicate?
    Image.exists?(:image_file_fingerprint => self.image_file_fingerprint)
  end

  def duplicate_images
    Image.where(:image_file_fingerprint => self.image_file_fingerprint).to_a
  end

  def exif
=begin
    if self.new_record?
      return false
    end
=end
=begin
bash shell extraction notes:
identify -format "%[EXIF:*]" ExifImage.jpg
a=`identify -format "%[EXIF:*]" ExifImage.jpg`

a.split("\n").collect{|b| b.gsub("exif:", "").split("=")}.inject({}){|hsh, c| hsh.merge(c[0]=>c[1])}

    # drop to the shell
=end
    # run an imageMagick command (identify?) pass to that command self.image_file.url

  end

  protected

  def extract_tw_attributes
    # NOTE: assumes content type is an image.
    tempfile = image_file.queued_for_write[:original]
    if tempfile.nil?
      self.width          = 0
      self.height         = 0
      self.user_file_name = ''
      #TODO should an error be thrown here?
    else
      self.user_file_name = tempfile.original_filename
      geometry            = Paperclip::Geometry.from_file(tempfile)
      self.width          = geometry.width.to_i
      self.height         = geometry.height.to_i
    end
  end

  #region soft_validation
  # Check md5 fingerprint against existing fingerprints
  def sv_duplicate_image?
    if has_duplicate?
      soft_validations.add(:image_file_fingerprint, 'This image is a duplicate of an image already stored.')
    end
  end

  #endregion  soft_validation
end
