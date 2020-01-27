# A SledImage contains the metadata to parse one image into many depictions.
#
# * if `metadata` is provided without a `collection_object` stub then Specimen is assumed
#
# A section is verbatim from sled
#
# @!attribute metadata
#   @return [JSON]
#     position coordinates
#
# @!attribute object_layout
#   @return [JSON]
#      ROI metadata per metadata type, expandable to all sled sections
#
class SledImage < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::Notes

  # Stubs coming from UI
  attr_accessor :collection_object_params # note, tag, deterimination

  # @param step_identifier [String]
  #  defaults to 'column', used only to compute object identifiers
  attr_accessor :step_identifier_on #row, column

  # If assigned to 'nuke', and .destroy, then will
  # additionall destroy all related collection objects
  attr_accessor :nuke

  # Internal processing
  attr_accessor :_first_identifier, :_row_total, :_column_total

  # A nil value occurs when `!section.metadata.nil?`
  attr_accessor :_identifier_matrix

  belongs_to :image
  has_many :depictions, through: :image
  has_many :collection_objects, through: :depictions, source: :depiction_object, source_type: 'CollectionObject'

#  before_destroy :destroy_collection_objects, if: Proc.new{|n| n.nuke == 'nuke'}
  before_destroy :destroy_related # depictions

  validates_presence_of :image
  validates_uniqueness_of :image_id

  # check for metadata etc., process if provide
  after_save :set_cached, unless: Proc.new {|n| n.metadata&.empty? || errors.any? }

  after_save :process, unless: Proc.new { |n| n.metadata&.empty? }

  # zero beers
  def total(direction = 'row')
    i = nil
    metadata.each do |o|
      i = o[direction] if i.nil? || (!i.nil? && o[direction] > i)
    end
    i
  end

  def metadata=(value)
    if value.kind_of? Array
      write_attribute(:metadata, value)
    elsif value.kind_of? String
      write_attribute(:metadata, JSON.parse(value))
    elsif value.nil?
      write_attribute(:metadata, [])
    else
      raise
    end
  end

  def summary
    m = []
    metadata.each do |s|
      c = s['column'].to_i
      r = s['row'].to_i
      m[r] ||= []
      d = depiction_for(s)
      m[r][c] = {
        depiction_id: d&.id,
        collection_object_id: d&.depiction_object_id,
        identifier: d&.depiction_object&.identifiers&.first&.cached
      }
    end
    m
  end

  def depiction_for(section)
    x,y = section['column'], section['row']
    depictions.where(sled_image_x_position: x, sled_image_y_position: y).first
  end

  private

  def destroy_related
    if nuke == 'nuke'
      collection_objects.reload.each do |d|
        d.destroy
      end
    end

    depictions.each do |d|
      d.destroy
    end
    true
  end

  def new_collection_object
    CollectionObject.new(collection_object_params)
  end

  def _first_identifier
    @_first_identifier ||= new_collection_object.identifiers&.first&.identifier&.to_i
  end

  def _row_total
    @_row_total ||= total('row')
  end

  def _column_total
    @_column_total ||= total('column')
  end

  # @return [Array of Arrays]
  def _identifier_matrix
    @_identifier_matrix ||= get_identifier_matrix
  end

  def get_identifier_matrix
    m = []
    i = _first_identifier
    metadata.each do |s|
      if !s['metadata'].blank?
        i += 1
        next
      end

      c = s['column'].to_i
      r = s['row'].to_i
      m[r] ||= []
      inc = r + c - i

      v = nil
      case step_identifier_on || 'column'
      when 'row'
        v = (r * _column_total) + inc
      when 'column'
        v = (c * _row_total) + inc
      end

      m[r][c] = v
    end
    @_identifier_matrix = m
  end

  def identifier_for(section)
    _identifier_matrix[section['row'].to_i][section['column'].to_i]
  end

  def process
    depictions.any? ?  syncronize : create_objects
  end

  def create_objects
    return true unless !collection_object_params.nil?
    begin
      metadata.each do |i|
        p = collection_object_params.merge(
          depictions_attributes: [
            {
              sled_image_id: id,
              image_id: image_id,
              svg_clip: svg_clip(i),
              sled_image_x_position: i['column'],
              sled_image_y_position: i['row']

            }
          ]
        )
        c = CollectionObject.new(p)
        if c.identifiers.first
          c.identifiers.first.identifier = identifier_for(i)
        end
        c.save!
      end
    rescue ActiveRecord::RecordInvalid
      raise
    end
  end

  def syncronize
    if metadata_was == []
      process if !metadata&.empty?
    else
      # At this point we only allow coordinate updates
      metadata.each do |i|
        next if i['metadata'].nil?
        if d = depiction_for(i)
          d.update_columns(
            svg_clip: svg_clip(i),
            svg_view_box: svg_view_box(i)
          )
        end
      end
    end
  end

  def set_cached
    update_columns(
      cached_total_collection_objects: total_metadata_objects,
      cached_total_rows: _row_total,
      cached_total_columns: _column_total
    )
  end

  def total_metadata_objects
    metadata.count
  end

  # x1, y1, y1, y2
  def coordinates(section)
    [
      section['upperCorner']['x'].to_f, section['upperCorner']['y'].to_f ,
      section['lowerCorner']['x'].to_f, section['lowerCorner']['y'].to_f]
  end

  def svg_view_box(section)
    x1, y1, x2, y2 = coordinates(section)
    [x1, y1, x2 - x1, y2 - y1].join(' ')
  end

  def svg_clip(section)
    x1, y1, x2, y2 = coordinates(section)
    "<rect x=\"#{x1}\" y=\"#{y1}\" width=\"#{x2 - x1}\" height=\"#{y2 - y1}\" />"
  end

end
