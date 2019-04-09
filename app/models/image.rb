# An Image is just that, as it is stored in the filesystem.  No additional metadata beyond file descriptors is included here.
#
# This class relies on the paperclip gem and the ImageMagik app to link, store and manipulate images.
#
# @!attribute user_file_name
#   @return [String]
#   The name of the file as uploaded by the user.
#
# @!attribute height
#   @return [Integer]
#     the height of the source image in px
#
# @!attribute width
#   @return [Integer]
#     the width of the source image in px
#
# @!attribute image_file_fingerprint
#   @return [String]
#   Added by paperclip; MD5 for the image file
#
# @!attribute image_file_file_name
#   @return [String]
#   Added by paperclip; the filename after processing to remove special characters.
#
# @!attribute image_file_content_type
#   @return [String]
#   Added by paperclip; the MIME (must be image) and file type (e.g. image/png).
#
# @!attribute image_file_file_size
#   @return [Integer]
#   Added by paperclip
#
# @!attribute image_file_updated_at
#   @return [Integer]
#   Added by paperclip
#
# @!attribute image_file_meta
#   @return (String)
#   Added by paperclip_meta gem, stores the sizes of derived images
#
class Image < ApplicationRecord
  include Housekeeping

  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::ProtocolRelationships
  include Shared::Citations
  include Shared::Attributions
  include Shared::IsData
  include SoftValidation

  MISSING_IMAGE_PATH = '/public/images/missing.jpg'.freeze

  has_many :depictions, inverse_of: :image, dependent: :restrict_with_error

  
  has_many :collection_objects, through: :depictions, source: :depiction_object, source_type: 'CollectionObject'
  has_many :otus, through: :depictions, source: :depiction_object, source_type: 'Otu'
  has_many :taxon_names, through: :otus

  before_save :extract_tw_attributes

  # also using https://github.com/teeparham/paperclip-meta
  has_attached_file :image_file,
    styles: {medium: ['300x300>', :jpg], thumb: ['100x100>', :png]},
    default_url: MISSING_IMAGE_PATH,
    filename_cleaner:  Utilities::CleanseFilename

  #:restricted_characters => /[^A-Za-z0-9\.]/,
  validates_attachment_content_type :image_file, content_type: /\Aimage\/.*\Z/
  validates_attachment_presence :image_file
  validates_attachment_size :image_file, greater_than: 1.kilobytes

  soft_validate(:sv_duplicate_image?)

  # @return [Boolean]
  def has_duplicate?
    Image.where(image_file_fingerprint: self.image_file_fingerprint).count > 1
  end

  # @return [Array]
  def duplicate_images
    Image.where(image_file_fingerprint: self.image_file_fingerprint).not_self(self).to_a
  end

  # @return [Hash]
  def exif
    # returns a hash of EXIF data if present, empty hash if not.do
    # EXIF data tags/specifications -  http://web.archive.org/web/20131018091152/http://exif.org/Exif2-2.PDF

    ret_val = {} # return value

    unless self.new_record? # only process if record exists
      tmp     = `identify -format "%[EXIF:*]" #{self.image_file.url}` # returns a string (exif:tag=value\n)
      # following removes the exif, spits and recombines string as a hash
      ret_val = tmp.split("\n").collect { |b| b.gsub('exif:', '').split('=') }
                  .inject({}) { |hsh, c| hsh.merge(c[0] => c[1]) }
      # might be able to tmp.split("\n").collect { |b|
      # b.gsub("exif:", "").split("=")
      # }.inject(ret_val) { |hsh, c|
      #   hsh.merge(c[0] => c[1])
      # }
    end

    ret_val # return
  end

  # @return [Nil]
  def gps_data
    # if there is EXIF data, pulls out geographic coordinates & returns hash of lat/long in decimal degrees
    # (5 digits after decimal point if available)
    # EXIF gps information is in http://web.archive.org/web/20131018091152/http://exif.org/Exif2-2.PDF section 4.6.6
    # note that cameras follow specifications, but EXIF data can be edited manually and may not follow specifications.

    # check if gps data is in d m s (could be edited manually)
    #   => format dd/1,mm/1,ss/1 or dd/1,mmmm/100,0/1 or 40/1, 5/1, 314437/10000
    # N = +
    # S = -
    # E = +
    # W = -
    # Altitude should be based on reference of sea level
    # GPSAltitudeRef is 0 for above sea level, and 1 for below sea level

    # From discussion with Jim -
    # create a utility library called "GeoConvert" and define single method
    # that will convert from degrees min sec to decimal degree
    # - maybe 2 versions? - one returns string, other decimal?

  end

  # Returns the true, unscaled height/width ratio
  # @return [Float]
  def hw_ratio
    raise if height.nil? || width.nil? # if they are something has gone badly wrong
    return (height.to_f / width.to_f)
  end

  # rubocop:disable Style/StringHashKeys
  # used in ImageHelper#image_thumb_tag
  # asthetic scaling of very narrow images in thumbnails
  # @return [Hash]
  def thumb_scaler
    a = self.hw_ratio
    if a < 0.6
      { 'width' => 200, 'height' => 200 * a}
    else
      {}
    end
  end
  # rubocop:enable Style/StringHashKeys

  # the scale factor is typically the same except in a few cases where we skew small thumbs
  # @param [Symbol] size
  # @return [Float]
  def width_scale_for_size(size = :medium)
    (width_for_size(size).to_f / width.to_f)
  end

  # @param [Symbol] size
  # @return [Float]
  def height_scale_for_size(size = :medium)
    height_for_size(size).to_f / height.to_f
  end

  # @param [Symbol] size
  # @return [Float]
  def width_for_size(size = :medium)
    a = self.hw_ratio
    case size
    when :thumb
      a < 0.6 ? 200.0 : ((width.to_f / height.to_f ) * 160.0)
    when :medium
      a < 1 ? 640.0 : 640.0 / a
    when :big
      a < 1 ? 1600.0 : 1600.0 / a
    when :original
      width
    else
      nil
    end
  end

  # @param [Symbol] size
  # @return [Float]
  def height_for_size(size = :medium)
    a = self.hw_ratio
    case size
    when :thumb
      a < 0.6 ? 213.0 * height.to_f / width.to_f : 160
    when :medium
      a < 1 ? a * 640 : 640
    when :big
      a < 1 ? a * 1600 : 1600
    when :original
      height
    else
      nil
    end
  end

  #  def filename(layout_section_type)
  #    'tmp/' + tempfile(layout_section_type).path.split('/').last
  #  end

  #  def tempfile(layout_section_type)
  #    tempfile = Tempfile.new([layout_section_type.to_s, '.jpg'], "#{Rails.root.to_s}/public/images/tmp", encoding: 'ASCII-8BIT' )
  #    tempfile.write(zoomed_image(layout_section_type).to_blob)
  #    tempfile
  #  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.cropped(params)
    image = Image.find(params[:id])
    img = Magick::Image.read(image.image_file.path(:original)).first

    cropped = img.crop(
                       params[:x].to_i,
                       params[:y].to_i,
                       params[:width].to_i,
                       params[:height].to_i,
                       true
                      )
    cropped
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.resized(params)
    c = cropped(params)
    c.resize(params[:new_width].to_i, params[:new_height].to_i)
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.scaled_to_box(params)
    c = cropped(params)
    ratio = c.columns.to_f / c.rows.to_f
    box_ratio = params[:box_width].to_f / params[:box_height].to_f

    if box_ratio > 1
      if ratio > 1 # wide into wide
        c.resize(params[:box_width ].to_i, (params[:box_height].to_f / ratio * box_ratio).to_i)
      else # tall into wide
        c.resize((params[:box_width ].to_f * ratio / box_ratio).to_i, params[:box_height].to_i )
      end
    else # <
      if ratio > 1 # wide into tall
        c.resize(params[:box_width].to_i, (params[:box_height].to_f / ratio * box_ratio).to_i)
      else # tall into tall
        c.resize((params[:box_width ].to_f * ratio * box_ratio ).to_i, (params[:box_height].to_f ).to_i)
      end
    end
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.scaled_to_box_blob(params)
    scaled_to_box(params).to_blob
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.resized_blob(params)
    resized(params).to_blob
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.cropped_blob(params)
    cropped(params).to_blob
  end

  protected

  # @return [Integer, Nil]
  def extract_tw_attributes
    # NOTE: assumes content type is an image.
    tempfile = image_file.queued_for_write[:original]
    if tempfile.nil?
      self.width = 0
      self.height = 0
      self.user_file_name = nil
    else
      self.user_file_name = tempfile.original_filename
      geometry = Paperclip::Geometry.from_file(tempfile)
      self.width = geometry.width.to_i
      self.height = geometry.height.to_i
    end
  end

  # Check md5 fingerprint against existing fingerprints
  # @return [Object]
  def sv_duplicate_image?
    if has_duplicate?
      soft_validations.add(:image_file_fingerprint,
                           'This image is a duplicate of an image already stored.')
    end
  end

end
