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
# @!attribute pixels_to_centimeter
#   @return [Float, nil]
#      used to generate scale bars on the fly
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

  include Image::Sled

  attr_accessor :rotate

  MISSING_IMAGE_PATH = '/public/images/missing.jpg'.freeze

  DEFAULT_SIZES = {
    thumb: { width: 100, height: 100 },
    medium: { width: 300, height: 300 }
  }.freeze

  has_one :sled_image, dependent: :destroy

  has_many :depictions, inverse_of: :image, dependent: :restrict_with_error

  has_many :collection_objects, through: :depictions, source: :depiction_object, source_type: 'CollectionObject'
  has_many :otus, through: :depictions, source: :depiction_object, source_type: 'Otu'
  has_many :taxon_names, through: :otus

  before_save :extract_tw_attributes

  # also using https://github.com/teeparham/paperclip-meta
  has_attached_file :image_file,
    styles: {
    thumb: [ "#{DEFAULT_SIZES[:thumb][:width]}x#{DEFAULT_SIZES[:thumb][:height]}>", :png ] ,
    medium: [ "#{DEFAULT_SIZES[:medium][:width]}x#{DEFAULT_SIZES[:medium][:height]}>", :jpg ]
  },
  default_url: MISSING_IMAGE_PATH,
  filename_cleaner: Utilities::CleanseFilename,
  processors: [:rotator]

  #:restricted_characters => /[^A-Za-z0-9\.]/,
  validates_attachment_content_type :image_file, content_type: /\Aimage\/.*\Z/
  validates_attachment_presence :image_file
  validate :image_dimensions_too_short

  soft_validate(:sv_duplicate_image?)

  accepts_nested_attributes_for :sled_image, allow_destroy: true

  # @return [Boolean]
  def has_duplicate?
    Image.where(image_file_fingerprint: self.image_file_fingerprint).count > 1
  end

  # @return [Array]
  def duplicate_images
    Image.where(image_file_fingerprint: self.image_file_fingerprint).not_self(self).to_a
  end

  # @return [Hash]
  # returns a hash of EXIF data if present, empty hash if not.do
  # EXIF data tags/specifications -  http://web.archive.org/web/20131018091152/http://exif.org/Exif2-2.PDF
  def exif
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
  #  currently handling this client side
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
    begin
    # img.crop(x, y, width, height, true)
      cropped = img.crop( params[:x].to_i, params[:y].to_i, params[:width].to_i, params[:height].to_i, true)
    rescue RuntimeError
      cropped = img.crop(0,0, 1, 1)  # return a single pixel on error ! TODO: make/return an error image
    ensure
      img.destroy!
    end
    cropped
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.resized(params)
    c = cropped(params)
    resized = c.resize(params[:new_width].to_i, params[:new_height].to_i) #.sharpen(0x1)
    c.destroy!
    resized
  end

  # @param [ActionController::Parameters] params
  # @return [Magick::Image]
  def self.scaled_to_box(params)
    c = cropped(params)
    ratio = c.columns.to_f / c.rows.to_f
    box_ratio = params[:box_width].to_f / params[:box_height].to_f
    # TODO: special considerations for 1:1?

    if box_ratio > 1
      if ratio > 1 # wide into wide
        scaled = c.resize(
          params[:box_width].to_i,
          (params[:box_height].to_f / ratio * box_ratio).to_i
        ) #.sharpen(0x1)
      else # tall into wide
        scaled = c.resize(
          (params[:box_width ].to_f * ratio / box_ratio).to_i,
          params[:box_height].to_i
        ) #.sharpen(0x1)
      end
    else # <
      if ratio > 1 # wide into tall
        scaled = c.resize(
          params[:box_width].to_i,
          (params[:box_height].to_f / ratio * box_ratio).to_i
        ) #.sharpen(0x1)
      else # tall into tall # TODO: or 1:1?!
        scaled = c.resize(
          (params[:box_width ].to_f * ratio / box_ratio ).to_i,
          (params[:box_height].to_f ).to_i
        ) #.sharpen(0x1)
      end
    end
    c.destroy!

    scaled
  end

  # @param [ActionController::Parameters] params
  # @return [String]
  def self.scaled_to_box_blob(params)
    self.to_blob!(scaled_to_box(params))
  end

  # @param [ActionController::Parameters] params
  # @return [String]
  def self.resized_blob(params)
    self.to_blob!(resized(params))
  end

  # @param [ActionController::Parameters] params
  # @return [String]
  def self.cropped_blob(params)
    self.to_blob!(cropped(params))
  end

  # @param used_on [String] required, a depictable base class name like  `Otu`, `Content`, or `CollectionObject`
  # @return [Scope]
  #   the max 10 most recently used images, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '')
    i = arel_table
    d = Depiction.arel_table

    # i is a select manager
    j = d.project(d['image_id'], d['updated_at'], d['depiction_object_type']).from(d)
      .where(d['updated_at'].gt( 1.weeks.ago ))
      .where(d['updated_by_id'].eq(user_id))
      .where(d['project_id'].eq(project_id))
      .order(d['updated_at'].desc)

    z = j.as('recent_i')

    k = Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
      z['image_id'].eq(i['id']).and(z['depiction_object_type'].eq(used_on))
    ))

    joins(k).distinct.pluck(:id)
  end

  # @params target [String] required, one of nil, `AssertedDistribution`, `Content`, `BiologicalAssociation`, 'TaxonDetermination'
  # @return [Hash] images optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: Image.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if target && !r.empty?
      h[:recent] = (
        Image.where('"images"."id" IN (?)', r.first(5) ).to_a +
        Image.where(project_id: project_id, created_by_id: user_id, created_at: 3.hours.ago..Time.now)
        .order('updated_at DESC')
        .limit(3).to_a
      ).uniq.sort{|a,b| a.updated_at <=> b.updated_at}

      h[:quick] = (
        Image.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a +
        Image.where('"images"."id" IN (?)', r.first(4) ).to_a)
        .uniq.sort{|a,b| a.updated_at <=> b.updated_at}
    else
      h[:recent] = Image.where(project_id: project_id).order('updated_at DESC').limit(10).to_a
      h[:quick] = Image.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id: project_id}).order('updated_at DESC')
    end

    h
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
      soft_validations.add(
        :image_file_fingerprint,
        'This image is a duplicate of an image already stored.')
    end
  end

  private

  # Converts image to blob and releases memory of img (image cannot be used afterwards)
  # @param [Magick::Image] img
  # @return [String] a JPG representation of the image
  # !! Always converts to .jpg, this may need abstraction later
  def self.to_blob!(img)
    img.format = 'jpg'
    blob = img.to_blob
    img.destroy!
    blob
  end

  def image_dimensions_too_short
    return unless original = image_file.queued_for_write[:original]

    dimensions = Paperclip::Geometry.from_file(original)

    errors.add(:image_file, "width must be at least 16 pixels") if dimensions.width < 16
    errors.add(:image_file, "height must be at least 16 pixels") if dimensions.height < 16
  rescue
    errors.add(:image_file, "unable to extract image dimensions")
  end

end
