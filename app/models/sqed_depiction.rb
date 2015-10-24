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
#    Not presently used, a cache for the result 
#
# @!attribute result_text
#   @return [Hash]
#    Not presently used, a cache for the ocr result 
#
class SqedDepiction < ActiveRecord::Base
  include Housekeeping
  include Shared::Taggable
  include Shared::Notable

  belongs_to :depiction
#  has_one :depiction_object, through: :depiction

  has_one :image, through: :depiction

  validates_presence_of :depiction
  validates_presence_of :metadata_map, :boundary_color
  validates_inclusion_of :layout, in: SqedConfig::LAYOUTS.keys.map(&:to_s)
  validates_inclusion_of :boundary_finder, in: %w{Sqed::BoundaryFinder::ColorLineFinder Sqed::BoundaryFinder::Cross}
  validates_inclusion_of :has_border, :in => [true, false]

  accepts_nested_attributes_for :depiction

  def extraction_metadata
    {
      boundary_color: self.boundary_color.to_sym,
      boundary_finder: boundary_finder,
      has_border: self.has_border,
      layout: self.layout.to_sym,          
      metadata_map: sqed_metadata_map
    }
 end

  def depiction_object
    depiction.depiction_object
  end

  # @return [SqedDepiction]
  #   the next record in which the collection object has no buffered data
  def next_without_data
    object = CollectionObject.joins(:sqed_depictions).where(project_id: self.project_id, buffered_collecting_event: nil, buffered_determinations: nil, buffered_other_labels: nil).where('collection_objects.id <> ?', self.depiction_object.id).order(:id).first
    object.nil? ? SqedDepiction.where(project_id: self.project_id).order(:id).first : object.sqed_depictions.first
  end

  protected

  def sqed_metadata_map
    self.metadata_map.inject({}){|hsh, i| hsh.merge(i[0].to_i => i[1].to_sym)}
  end 

end
