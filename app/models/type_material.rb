# TypeMaterial is a definition of goverened type
#
# @!attribute protonym_id
#   @return [Integer]
#     the protonym in question
#
# @!attribute biological_object_id
#   @return [Integer]
#     the specimen record
#
# @!attribute type_type
#   @return [String]
#     the type of Type relationship (e.g. holotyp)
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
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Notes
  include Shared::Tags
  include SoftValidation

  # Keys are valid values for type_type, values are
  # required Class for material
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
  }

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
  }

  belongs_to :material, foreign_key: :biological_object_id, class_name: 'CollectionObject', inverse_of: :type_designations
  belongs_to :protonym
  has_many :type_designator_roles, class_name: 'TypeDesignator', as: :role_object
  has_many :type_designators, through: :type_designator_roles, source: :person

  accepts_nested_attributes_for :type_designators, :type_designator_roles, allow_destroy: true
  accepts_nested_attributes_for :material, allow_destroy: true


  scope :where_protonym, -> (taxon_name) {where(protonym_id: taxon_name)}
  scope :with_type_string, -> (base_string) {where('type_type LIKE ?', "#{base_string}" ) }
  scope :with_type_array, -> (base_array) {where('type_type IN (?)', base_array ) }

  scope :primary, -> {where(type_type: %w{neotype lectotype holotype}).order('biological_object_id')}
  scope :syntypes, -> {where(type_type: %w{syntype syntypes}).order('biological_object_id')}

  #  scope :primary_with_protonym_array, -> (base_array) {select('type_type, source_id, biological_object_id').group('type_type, source_id, biological_object_id').where("type_materials.type_type IN ('neotype', 'lectotype', 'holotype', 'syntype', 'syntypes') AND type_materials.protonym_id IN (?)", base_array ) }
  scope :primary_with_protonym_array, -> (base_array) {select('type_type, biological_object_id').group('type_type, biological_object_id').where("type_materials.type_type IN ('neotype', 'lectotype', 'holotype', 'syntype', 'syntypes') AND type_materials.protonym_id IN (?)", base_array ) }

  soft_validate(:sv_single_primary_type, set: :single_primary_type)
  soft_validate(:sv_type_source, set: :type_source)

  validates :protonym, presence: true
  validates :material, presence: true
  validates_presence_of :type_type

  validate :check_type_type

  # TODO: really should be validating uniqueness at this point, it's type material, not garbage records

  def type_source
    if !!self.source
      self.source
    elsif !!self.protonym
      if !!self.protonym.source
        self.protonym.source
      else
        nil
      end
    else
      nil
    end
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  #region Validation

  def check_type_type
    if self.protonym
      code = self.protonym.rank_class.nomenclatural_code
      if (code == :iczn && !ICZN_TYPES.keys.include?(self.type_type)) || (code == :icn && !ICN_TYPES.keys.include?(self.type_type))
        errors.add(:type_type, 'Not a legal type for the nomenclatural code provided')
      end
      unless self.protonym.rank_class.parent.to_s =~ /Species/
        errors.add(:protonym_id, 'Type cannot be designated, name is not a species group name')
      end
    end
  end

  #endregion

  #region Soft Validation

  def sv_single_primary_type
    primary_types = TypeMaterial.with_type_array(['holotype', 'neotype', 'lectotype']).where_protonym(self.protonym).not_self(self)
    syntypes = TypeMaterial.with_type_array(['syntype', 'syntypes']).where_protonym(self.protonym)
    if self.type_type == 'syntype' || self.type_type == 'syntypes'
      soft_validations.add(:type_type, 'Other primary types selected for the taxon are conflicting with the syntypes') unless primary_types.empty?
    end
    if self.type_type == 'holotype' || self.type_type == 'neotype' || self.type_type == 'lectotype'
      soft_validations.add(:type_type, 'More than one primary type associated with the taxon') if !primary_types.empty? || !syntypes.empty?
    end
  end

  def sv_type_source
    soft_validations.add(:base, 'Source is not selected neither for type nor for taxon') unless type_source
  end

  #endregion
end
