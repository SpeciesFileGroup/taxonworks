# A SqedDepiction identifies a depiction as sqed (https://github.com/SpeciesFileGroup/sqed) parsable, and
# records the metadata required for parsing a stage image.
#
# @!attribute boundary_color 
#   @return [Symbol]
#   Color of the boundaries in the image, default/recommendation is green.
# 
# @!attribute boundary_finder 
#   @return [String]
#   Name of the sqed BoundaryFinder class to use, e.g. 'Sqed::BoundaryFinder::ColorLineFinder'
#
# @!attribute has_border  
#   @return [Boolean]
#     True if the stage image has a border than needs to be detected
#
# @!attribute layout  
#   @return [Symbol]
#   The Sqed layout, like :cross, :equal_cross, :vertical_offset_cross, :internal_box etc.
#
# @!attribute metadata_map  
#   @return [Hash]
#   The sqed metadata map, e.g. {0 => :curator_metadata, 1 => :identifier, 2 => :image_registration, 3 => :annotated_specimen }.  
#
# @!attribute specimen_coordinates 
#   @return [Hash]
#    Not presently used, the specific coordinates bounding the specimen(s) only
#
# @!attribute result_boundaries 
#   @return [Hash]
#    A cache for the result 
#
# @!attribute result_ocr
#   @return [Hash]
#    A cache for the ocr result 
#
class SqedDepiction < ActiveRecord::Base
  include Housekeeping
  include Shared::Taggable
  include Shared::Notable

  belongs_to :depiction
  #  has_one :depiction_object, through: :depiction

  has_one :image, through: :depiction

  validates_presence_of  :depiction
  validates_presence_of  :metadata_map, :boundary_color
  validates_inclusion_of :layout, in: SqedConfig::LAYOUTS.keys.map(&:to_s)
  validates_inclusion_of :boundary_finder, in: %w{Sqed::BoundaryFinder::ColorLineFinder Sqed::BoundaryFinder::Cross}
  validates_inclusion_of :has_border, :in => [true, false]

  accepts_nested_attributes_for :depiction

  def extraction_metadata
    {
      boundary_color: boundary_color.to_sym,
      boundary_finder: boundary_finder,
      has_border: has_border,
      target_layout: layout.to_sym,
      target_metadata_map: sqed_metadata_map
    }
 end

  def depiction_object
    depiction.depiction_object
  end

  def self.without_collection_object_data
    CollectionObject.joins(:sqed_depictions).where(buffered_collecting_event: nil, buffered_determinations: nil, buffered_other_labels: nil)
  end

  # @return [SqedDepiction]
  #   the next record in which the collection object has no buffered data
  def next_without_data
    object =  SqedDepiction.without_collection_object_data.with_project_id(project_id).where('collection_objects.id <> ?', self.depiction_object.id).order(:id).first
    object.nil? ? SqedDepiction.where(project_id: project_id).order(:id).first : object.sqed_depictions.first
  end

  # @return [CollectionObject, nil]
  #    the next collection object, by :id, created from the addition of a SqedDepiction
  def next_collection_object
    object = CollectionObject.joins(:sqed_depictions).where(project_id: project_id).where('sqed_depictions.id > ?', id).where('collection_objects.id <> ?', depiction_object.id).order(:id).first
    object = CollectionObject.joins(:sqed_depictions).order(:id).first if object.nil?
    object
  end

  # @return [Array of symbols]
  #   the (named) sections in this depiction that may have collecting event label metadata
  def collecting_event_sections
    [:collecting_event_labels, :annotated_specimen] & extraction_metadata[:metadata_map].values
  end

  def nearby_sqed_depictions(before = 5, after = 5)
    a = SqedDepiction.where(project_id: project_id).where("id > ?", id).order(:id).limit(after)
    b = SqedDepiction.where(project_id: project_id).where("id < ?", id).order('id DESC').limit(before)
    return { before: b, after: a}
  end

  def next_sqed_depiction
    sd = SqedDepiction.where(project_id: project_id).where("id > ?", id).order(:id).limit(1)
    sd.any? ? sd.first : SqedDepiction.where(project_id: project_id).first
  end

  def preprocess
    result = SqedToTaxonworks::Result.new(depiction_id: depiction.id)
    result.cache_all
  end

  # @return [Integer]
  #   caches section coordinates and ocr text for the first images that don't have such caches !! does not take into account, just finds and processes
  def self.preprocess_empty(total = 10)
    t = SqedDepiction.arel_table
    i = 0
    while i < total
      r = SqedDepiction.where(t[:result_ocr].eq(nil).or(t[:result_boundary_coordinates].eq(nil)).to_sql).limit(1).first
      return i if r.nil?
      r.preprocess
      i = i + 1
    end
    i
  end

  protected

  def sqed_metadata_map
    metadata_map.inject({}){|hsh, i| hsh.merge(i[0].to_i => i[1].to_sym)}
  end 

end
