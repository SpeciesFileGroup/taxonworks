# An Extract is the quantified physical entity that originated from a CollectionObject.
# Extracts are linked to their origin through an OriginRelationship.
#
# @!attribute verbatim_anatomical_origin
#  @return [String]
#    proxy for a OriginRelationship to an AnatomicalClass
#
# @!attribute year_made
#  @return [Integer]
#    4 digit year the extract originated
#
# @!attribute month_made
#  @return [Integer]
#    2 digit month the extract originated
#
# @!attribute day_made
#  @return [Integer]
#    2 digit day the extract originated
#
class Extract < ApplicationRecord
  include Housekeeping
  include Shared::Identifiers
  include Shared::ProtocolRelationships
  include Shared::OriginRelationship
  include Shared::Containable
  include Shared::DataAttributes
  include Shared::HasRoles
  include SoftValidation
  include Shared::IsData

  is_origin_for 'Extract', 'Sequence'
  originates_from 'Extract', 'Specimen', 'Lot', 'RangedLot', 'Otu'

  belongs_to :repository, inverse_of: :extracts

  has_many :sequences, through: :origin_relationships, source: :new_object, source_type: 'Sequence'

  has_many :extractor_roles, -> { order('roles.position ASC') }, class_name: 'Extractor', as: :role_object, dependent: :destroy, validate: true
  has_many :extractors, through: :extractor_roles, source: :person

  # validates_presence_of :quantity_value
  attr_accessor :is_made_now

  before_validation :set_made, if: -> {is_made_now}

  validates :year_made, date_year: { min_year: 1757, max_year: -> {Time.now.year} }
  validates :month_made, date_month: true
  validates :day_made, date_day: {year_sym: :year_made, month_sym: :month_made}, unless: -> {year_made.nil? || month_made.nil?}

  protected

  def set_made
    write_attribute(:year_made, Time.now.year)
    write_attribute(:month_made, Time.now.month)
    write_attribute(:day_made, Time.now.day)
  end

  # @param used_on [String] required, one of `Protocol`, `OriginRelationship`
  # @return [Scope]
  #    the max 10 most recently used collection_objects, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '')
    return [] if used_on != 'TaxonDetermination' && used_on != 'BiologicalAssociation'
    t = case used_on
        when 'TaxonDetermination'
          TaxonDetermination.arel_table
        when 'BiologicalAssociation'
          BiologicalAssociation.arel_table
        end

    p = CollectionObject.arel_table

    # i is a select manager
    i = case used_on
        when 'BiologicalAssociation'
          t.project(t['biological_association_subject_id'], t['updated_at']).from(t)
            .where(
              t['updated_at'].gt(1.weeks.ago).and(
                t['biological_association_subject_type'].eq('CollectionObject') # !! note it's not biological_collection_object_id
              )
            )
              .where(t['created_by_id'].eq(user_id))
              .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        else
          t.project(t['biological_collection_object_id'], t['updated_at']).from(t)
            .where(t['updated_at'].gt( 1.weeks.ago ))
            .where(t['created_by_id'].eq(user_id))
            .where(t['project_id'].eq(project_id))
            .order(t['updated_at'].desc)
        end

    # z is a table alias
    z = i.as('recent_t')

    j = case used_on
        when 'BiologicalAssociation'
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z['biological_association_subject_id'].eq(p['id'])
          ))
        else
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['biological_collection_object_id'].eq(p['id']))) # !! note it's not biological_collection_object_id
        end

    CollectionObject.joins(j).pluck(:id).uniq
  end

  # @params target [String] one of `TaxonDetermination`, `BiologicalAssociation` , nil
  # @return [Hash] otus optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: Extract.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: []
    }

    if target && !r.empty?
      n = target.tableize.to_sym
      h[:recent] = Extract.where('"extracts"."id" IN (?)', r.first(10) ).to_a
      h[:quick] = (Extract.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a  +
          Extract.where('"extracts"."id" IN (?)', r.first(4) ).to_a).uniq
    else
      h[:recent] = Extract.where(project_id: project_id, updated_by_id: user_id).order('updated_at DESC').limit(10).to_a
      h[:quick] = Extract.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a
    end

    h
  end

end
