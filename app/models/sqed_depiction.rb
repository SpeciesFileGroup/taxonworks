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
class SqedDepiction < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::Notes

  attr_accessor :rebuild

  belongs_to :depiction
  has_one :image, through: :depiction

  has_one :collection_object, through: :depiction, source_type: 'CollectionObject', source: :depiction_object 

  validates_presence_of :depiction
  validates_presence_of  :metadata_map, :boundary_color
  validates_inclusion_of :layout, in: SqedConfig::LAYOUTS.keys.map(&:to_s)
  validates_inclusion_of :boundary_finder, in: %w{Sqed::BoundaryFinder::ColorLineFinder Sqed::BoundaryFinder::Cross}
  validates_inclusion_of :has_border, in: [true, false]
  validate :depiction_is_of_collection_object

  accepts_nested_attributes_for :depiction

  after_save :recalculate, if: -> { rebuild }

  def rebuild=(value)
    @rebuild = value
  end

  def recalculate
    preprocess(true)
  end

  def extraction_metadata
    {
      boundary_color: boundary_color.to_sym,
      boundary_finder: boundary_finder&.constantize,
      has_border: has_border,
      layout: layout.to_sym,
      metadata_map: sqed_metadata_map
    }
  end

  def depiction_object
    depiction.depiction_object
  end

  def self.with_collection_object_data
    t = CollectionObject.arel_table
    q = t[:buffered_collecting_event].not_eq(nil).
      or(t[:buffered_determinations].not_eq(nil)).
      or(t[:buffered_other_labels].not_eq(nil))

    joins(:collection_object).where(q.to_sql)
  end

  def self.without_collection_object_data
    t = CollectionObject.arel_table
    q = t[:buffered_collecting_event].eq(nil).
      and(t[:buffered_determinations].eq(nil)).
      and(t[:buffered_other_labels].eq(nil))

    joins(:collection_object).where(q.to_sql)
  end

  # @return [SqedDepiction]
  #   the next record in which the collection object has no buffered data
  def next_without_data(progress = false)
    if progress
      SqedDepiction.clear_stale_progress(self) 
      object = SqedDepiction.without_collection_object_data.with_project_id(project_id).where('collection_objects.id <> ?', depiction_object.id).where('sqed_depictions.id > ?', id).order(:id).first
      object.nil? ? SqedDepiction.where(in_progress: false, project_id: project_id).order(:id).first : object
    else
      object = SqedDepiction.without_collection_object_data.with_project_id(project_id).where('collection_objects.id <> ?', depiction_object.id).where('sqed_depictions.id > ?', id).order(:id).first
      object.nil? ? SqedDepiction.where(project_id: project_id).order(:id).first : object
    end
  end

  def is_in_progress?
    in_progress && in_progress < 5.minutes.ago
  end

  def self.clear_stale_progress(sqed_depiction = nil)
    SqedDepiction.where('(in_progress < ?)', 5.minutes.ago)
      .update_all(in_progress: nil)
    if sqed_depiction
      SqedDepiction
        .where(updated_by_id: sqed_depiction.updated_by_id)
        .update_all(in_progress: nil)
    end
    true
  end

  def self.last_without_data(project_id)
    object = SqedDepiction.without_collection_object_data.with_project_id(project_id).order(:id).first
    object.nil? ? SqedDepiction.where(project_id: project_id).order(id: :asc).first : object
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
    # !! master merge
    [:collecting_event_labels, :annotated_specimen] & extraction_metadata[:metadata_map].values
  end

  def nearby_sqed_depictions(before = 5, after = 5, progress = false)
    q = SqedDepiction.where(project_id: project_id)

    if progress == true
      SqedDepiction.clear_stale_progress(self)
      q = q.where(in_progress: nil)
    end

    a = q.where('id > ?', id).order(:id).limit(after)
    b = q.where('id < ?', id).order('id DESC').limit(before)

    return { before: b, after: a}
  end

  def next_sqed_depiction
    sd = SqedDepiction.where(project_id: project_id).where('id > ?', id).order(:id).limit(1)
    sd.any? ? sd.first : SqedDepiction.where(project_id: project_id).first
  end

  def preprocess(force = true)
    return true if !File.exists?(depiction.image.image_file.path(:original))
    # don't rebuild if not forced and one or both cache is empty
    if !force
      if !result_ocr.blank? || !result_boundary_coordinates.blank?
        return true
      end
    end

    # otherwise rebuild
    result = SqedToTaxonworks::Result.new(depiction_id: depiction.id)
    result.cache_all
  end

  # @return [Integer]
  #   caches section coordinates and ocr text for the first images that don't have such caches !! does not take into account project or user, just finds and processes
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

  def depiction_is_of_collection_object
    if depiction
      errors.add(:depiction, 'must be of a collection object') if !(depiction.depiction_object_type =~ /CollectionObject/)
    end
  end

  def sqed_metadata_map
    metadata_map.inject({}){|hsh, i| hsh.merge(i[0].to_i => i[1].to_sym)}
  end

end
