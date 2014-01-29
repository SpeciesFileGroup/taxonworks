class TypeMaterial < ActiveRecord::Base
  belongs_to :source

  include Housekeeping
  include Shared::Citable
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

  belongs_to :material, foreign_key: :biological_object_id, class_name: 'CollectionObject'
  belongs_to :protonym
  has_many :type_designator_roles, class_name: 'TypeDesignator', as: :role_object
  has_many :type_designators, through: :type_designator_roles, source: :person

  scope :where_taxon_name, -> (taxon_name) {where(protonym_id: taxon_name)}
  scope :with_type_string, -> (base_string) {where('type_type LIKE ?', "#{base_string}" ) }
  scope :with_type_array, -> (base_array) {where('type_type IN (?)', base_array ) }
  scope :not_self, -> (id) {where('id != ?', id )}


  soft_validate(:sv_single_primary_type, set: :single_primary_type)

  validates :protonym, presence: true
  validates :material, presence: true
  validates_presence_of :type_type

  validate :check_type_type

  protected

  def check_type_type
    if self.protonym
      code = self.protonym.rank_class.nomenclatural_code 
      if (code == :iczn && !ICZN_TYPES.keys.include?(self.type_type)) || (code == :icn && !ICN_TYPES.keys.include?(self.type_type))
        errors.add(:type_type, 'Not a legal type for the nomenclatural code provided') 
      end
    end
  end

  def sv_single_primary_type
    primary_types = TypeMaterial.with_type_array('holotype', 'neotype', 'lectotype').not_self(self)
    syntypes = TypeMaterial.with_type_array('syntype', 'syntypes')
    if self.type_type = 'syntype' || self.type_type = 'syntypes'
      errors.add(:type_type, 'Other primary types selected for the taxon are conflicting with the syntypes') unless primary_types.empty?
    end
    if self.type_type = 'holotype' || self.type_type = 'neotype' || self.type_type = 'lectotype'
      errors.add(:type_type, 'More than one primary types associated with the taxon') unless primary_types.empty? && syntypes.empty?
    end
  end

end
