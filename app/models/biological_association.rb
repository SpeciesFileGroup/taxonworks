# A BiologicalAssociation defines a (biological) relationship between two entities.  It is an edge in the graph of biological relationships.
# The relationship can be between two Otus, an Otu and a Collection Object, or between two Collection Objects.
# For example 'Species Aus bus is the host_of individual A.'
#
# @!attribute biological_relationship_id
#   @return [Integer]
#     the BiologicalRelationship id
#
# @!attribute biological_association_subject_id
#   @return [Integer]
#     Rails polymorphic, id of the subject of the relationship
#
# @!attribute biological_association_subject_type
#   @return [String]
#    Rails polymorphic, type fo the subject (e.g. Otu)
#
# @!attribute biological_association_object_id
#   @return [Integer]
#     Rails polymorphic,  id of the object
#
# @!attribute biological_association_object_type
#   @return [String]
#    Rails polymorphic, type of the object (e.g. CollectionObject)
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalAssociation < ApplicationRecord
  include Housekeeping
  include SoftValidation
  include Shared::Citations
  include Shared::Tags
  include Shared::Identifiers
  include Shared::DataAttributes
  include Shared::Confidences
  include Shared::Notes
  include Shared::Confidences
  include Shared::IsData

  belongs_to :biological_relationship, inverse_of: :biological_associations

  has_many :subject_biological_relationship_types, through: :biological_relationship
  has_many :object_biological_relationship_types, through: :biological_relationship

  has_many :subject_biological_properties, through: :subject_biological_relationship_types, source: :biological_property
  has_many :object_biological_properties, through: :object_biological_relationship_types, source: :biological_property

  belongs_to :biological_association_subject, polymorphic: true
  belongs_to :biological_association_object, polymorphic: true
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_association
  has_many :biological_associations_graphs, through: :biological_associations_biological_associations_graphs, inverse_of: :biological_associations

  validates :biological_relationship, presence: true
  validates :biological_association_subject, presence: true
  validates :biological_association_object, presence: true

  validates_uniqueness_of :biological_association_subject_id, scope: [:biological_association_subject_type, :biological_association_object_id, :biological_association_object_type, :biological_relationship_id]

  validate :biological_association_subject_type_is_allowed
  validate :biological_association_object_type_is_allowed

  attr_accessor :subject_global_id
  attr_accessor :object_global_id

  # TODO: Why?! this is just biological_association.biological_association_subject_type
  def subject_class_name
    biological_association_subject.try(:class).base_class.name
  end

  # TODO: Why?! this is just biological_association.biological_association_object_type
  def object_class_name
    biological_association_object.try(:class).base_class.name
  end

  def subject_global_id=(value)
    o = GlobalID::Locator.locate(value)
    write_attribute(:biological_association_subject_id, o.id)
    write_attribute(:biological_association_subject_type, o.metamorphosize.class.name)
  end

  def object_global_id=(value)
    o = GlobalID::Locator.locate(value)
    write_attribute(:biological_association_object_id, o.id)
    write_attribute(:biological_association_object_type, o.metamorphosize.class.name)
  end

  # @return [ActiveRecord::Relation]
   #def self.collection_objects_subject_join
   #  a = arel_table
   #  b = ::CollectionObject.arel_table
   #  j = a.join(b).on(a[:biological_association_subject_type].eq('CollectionObject').and(a[:biological_association_subject_id].eq(b[:id])))
   #  joins(j.join_sources)
   #end

  # @return [ActiveRecord::Relation]
  def self.targeted_join(target: 'subject', target_class: ::Otu )
    a = arel_table
    b = target_class.arel_table

    j = a.join(b).on(a["biological_association_#{target}_type".to_sym].eq(target_class.name).and(a["biological_assoication_#{target}_id".to_sym].eq(b[:id])))
    joins(j.join_sources)
  end

  private

  def biological_association_subject_type_is_allowed
    errors.add(:biological_association_subject_type, 'is not permitted') unless biological_association_subject && biological_association_subject.class.is_biologically_relatable?
  end

  def biological_association_object_type_is_allowed
    errors.add(:biological_association_object_type, 'is not permitted') unless biological_association_object && biological_association_object.class.is_biologically_relatable?
  end

end
