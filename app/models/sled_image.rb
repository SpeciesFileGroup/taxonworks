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
  include Shared::IsData

  # Stubs coming from UI
  attr_accessor :collection_object_params # note, tag, deterimination

  # Stubs coming from UI
  attr_accessor :depiction_params # for is_metadata_depiction

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

  before_destroy :destroy_related

  validates_presence_of :image
  validates_uniqueness_of :image_id

  after_save :set_cached, unless: Proc.new {|n| n.metadata&.empty? || errors.any? } # must be before process
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

  def step_identifier_on
    @step_identifier_on ||= 'column'
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

  def identity_matrix
    i = []
    metadata.each do |s|
      r = s['row'].to_i
      c = s['column'].to_i
      i[r] ||= []
      i[r][c] = s['metadata'].blank? ? 0 : 1
    end
    i
  end

  def increment_matrix
    i = []
    j = identity_matrix
    k = 0
    case step_identifier_on
    when 'row'
      (0.._row_total).each do |r|
        (0.._column_total).each do |c|
          k += j[r][c]
          i[r] ||= []
          i[r][c] = (j[r][c] == 1 ? 0 : k)
        end
      end

    when 'column'
      (0.._column_total).each do |c|
        (0.._row_total).each do |r|
          k += j[r][c]
          i[r] ||= []
          i[r][c] = (j[r][c] == 1 ? 0 : k)
        end
      end
    end
    i
  end

  def get_identifier_matrix
    i = increment_matrix

    m = []

    metadata.each do |s|
      r = s['row'].to_i
      c = s['column'].to_i
      m[r] ||= []
      m[r][c] = nil if !s['metadata'].blank?
      next if !s['metadata'].blank? || _first_identifier.nil?

      inc = r + c - i[r][c] + _first_identifier
      v = nil
      case step_identifier_on
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
    true
  end

  def create_objects
    return true unless !collection_object_params.nil?
    begin
      metadata.each do |i|
        next unless i['metadata'].blank?
        p = collection_object_params.merge(
          depictions_attributes: [
            {
              sled_image_id: id,
              image_id: image_id,
              svg_clip: svg_clip(i),
              svg_view_box: svg_view_box(i),
              sled_image_x_position: i['column'],
              sled_image_y_position: i['row'],
              is_metadata_depiction: is_metadata_depiction?
            }
          ]
        )

        j = identifier_for(i)

        # Check to see if object exists
        if j && k = Identifier::Local::CatalogNumber.find_by(p[:identifiers_attributes].first.merge(identifier: j, identifier_object_type: 'CollectionObject'))
          # Remove the identifier attributes, identifier exists
          p.delete :identifiers_attributes
          p.delete :tags_attributes
          p.delete :notes_attributes
          p.delete :taxon_determinations_attributes
          p.delete :data_attributes_attributes
          p.delete :total

          k.identifier_object.update!(p)
        else
          c = CollectionObject.new(p)

          if c.identifiers.first
            c.identifiers.first.identifier = identifier_for(i)
          end
          c.save!
        end

      end
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      raise
    end
    true
  end

  def syncronize
    if metadata_was == []
      process if !metadata&.empty?
    else
      # At this point we only allow coordinate updates
      metadata.each do |i|
        next if !i['metadata'].nil?
        if d = depiction_for(i)
          d.update_columns(
            svg_clip: svg_clip(i),
            svg_view_box: svg_view_box(i),
          )
        end
      end
    end
    true
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

  # x1, y1, x2, y2
  def coordinates(section)
    [
      section['upperCorner']['x'].to_f, section['upperCorner']['y'].to_f,
      section['lowerCorner']['x'].to_f, section['lowerCorner']['y'].to_f]
  end


  def svg_view_box(section)
    view_box_values(section).join(' ')
  end

  # @return top left x, top left y, height, width
  def view_box_values(section)
    x1, y1, x2, y2 = coordinates(section)
    [x1, y1, x2 - x1, y2 - y1]
  end

  def svg_clip(section)
    x, y, h, w = view_box_values(section)
    "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{h}\" height=\"#{w}\" />"
  end

  private

  def is_metadata_depiction?
    if depiction_params && !depiction_params.empty?
      a = depiction_params[:is_metadata_depiction]
      ((a == 'true') || (a == true)) ? true : false
    else
      false
    end
  end

end
