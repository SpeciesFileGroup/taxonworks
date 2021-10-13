# TODO: Rename the insane column names here
#
# TypeMaterial links CollectionObjects to Protonyms.  It is the single direct relationship between nomenclature and collection objects in TaxonWorks (all other name/collection object relationships coming through OTUs).
# TypeMaterial is based on specific rules of nomenclature, it only includes those types (e.g. "holotype") that are specifically goverened (e.g. "topotype" is not allowed).
#
# @!attribute protonym_id
#   @return [Integer]
#     the protonym in question
#
# @!attribute collection_object_id
#   @return [Integer]
#     the CollectionObject
#
# @!attribute type_type
#   @return [String]
#     the type of Type relationship (e.g. holotype)
#
# @!attribute project_id
#   @return [Integer
#   the project ID
#
# @!attribute position
#   @return [Integer]
#    sort column
#
class TypeMaterial < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::HasRoles

  include Shared::Notes
  include Shared::Tags
  include Shared::Confidences
  include Shared::IsData
  include SoftValidation

  # Keys are valid values for type_type, values are
  # required Class for BiologicalCollectionObject
  ICZN_TYPES = {
    'holotype' =>  Specimen,
    'paratype' => Specimen,
    'paralectotype' => Specimen,
    'neotype' => Specimen,
    'lectotype' => Specimen,
    'syntype' => Specimen,
    'paratypes' => Lot,
    'syntypes' => Lot,
    'paralectotypes' => Lot
  }.freeze

  ICN_TYPES = {
      'holotype' => Specimen,
      'paratype' => Specimen,
      'lectotype' => Specimen,
      'neotype' => Specimen,
      'epitype' => Specimen,
      'isotype' => Specimen,
      'syntype' => Specimen,
      'isosyntype' => Specimen,
      'syntypes' => Lot,
      'isotypes' => Lot,
      'isosyntypes' => Lot
  }.freeze

  belongs_to :collection_object, foreign_key: :collection_object_id, class_name: 'CollectionObject', inverse_of: :type_materials
  belongs_to :protonym, inverse_of: :type_materials

  scope :where_protonym, -> (taxon_name) { where(protonym_id: taxon_name) }
  scope :with_type_string, -> (base_string) { where('type_type LIKE ?', "#{base_string}" ) }
  scope :with_type_array, -> (base_array) { where('type_type IN (?)', base_array ) }

  scope :primary, -> {where(type_type: %w{neotype lectotype holotype}).order('collection_object_id')}
  scope :syntypes, -> {where(type_type: %w{syntype syntypes}).order('collection_object_id')}
  scope :primary_with_protonym_array, -> (base_array) {select('type_type, collection_object_id').group('type_type, collection_object_id').where("type_materials.type_type IN ('neotype', 'lectotype', 'holotype', 'syntype', 'syntypes') AND type_materials.protonym_id IN (?)", base_array ) }

  validate :check_type_type
  validate :check_protonym_rank

  soft_validate(:sv_single_primary_type, set: :single_primary_type)
  soft_validate(:sv_type_source, set: :type_source)

  accepts_nested_attributes_for :collection_object, allow_destroy: true

  validates_presence_of :type_type, :protonym_id

  # !! breaks nested attributes if validated as collection_object_id.  Seems to be belongs_to only related.
  validates_presence_of :collection_object

  # TODO: really should be validating uniqueness at this point, it's type material, not garbage records

  def type_source
    [source, protonym.try(:source), nil].compact.first
  end

  def legal_type_type(code, type_type)
    case code
    when :iczn
      ICZN_TYPES.keys.include?(type_type)
    when :icn
      ICN_TYPES.keys.include?(type_type)
    else
      false
    end
  end

  def type_string

  end

  protected

  def check_type_type
    if protonym
      code = protonym.rank_class.nomenclatural_code
      errors.add(:type_type, 'Not a legal type for the nomenclatural code provided') if !legal_type_type(code, type_type)
    end
  end

  def check_protonym_rank
    errors.add(:protonym_id, 'Type cannot be designated, name is not a species group name') if protonym && !protonym.is_species_rank?
  end

  def sv_single_primary_type
    primary_types = TypeMaterial.with_type_array(['holotype', 'neotype', 'lectotype']).where_protonym(protonym).not_self(self)
    syntypes = TypeMaterial.with_type_array(['syntype', 'syntypes']).where_protonym(protonym)

    if type_type =~ /syntype/
      soft_validations.add(:type_type, 'Other primary types selected for the taxon are conflicting with the syntypes') unless primary_types.empty?
    end

    if ['holotype', 'neotype', 'lectotype'].include?(type_type)
      soft_validations.add(:type_type, 'More than one primary type associated with the taxon') if !primary_types.empty? || !syntypes.empty?
    end
  end

  def sv_type_source
    soft_validations.add(:base, 'Source is not selected neither for type nor for taxon') unless type_source
    if %w(paralectotype neotype lectotype paralectotypes).include?(type_type)
      if source.nil?
        soft_validations.add(:base, "Source for #{type_type} designation is not selected ") if source.nil?
      elsif !protonym.try(:source).nil? && source.nomenclature_date && protonym.nomenclature_date
        soft_validations.add(:base, "#{type_type.capitalize} could not be designated in the original publication") if source == protonym.source
        soft_validations.add(:base, "#{type_type.capitalize} could not be designated before taxon description") if source.nomenclature_date < protonym.nomenclature_date
      end
    end
  end

end
