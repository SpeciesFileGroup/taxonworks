class TypeMaterial < ActiveRecord::Base
  belongs_to :source

 include Housekeeping
  include Shared::Citable

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

end
