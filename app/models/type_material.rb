class TypeMaterial < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::IsData
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
  belongs_to :source
  has_many :type_designator_roles, class_name: 'TypeDesignator', as: :role_object
  has_many :type_designators, through: :type_designator_roles, source: :person

  scope :where_protonym, -> (taxon_name) {where(protonym_id: taxon_name)}
  scope :with_type_string, -> (base_string) {where('type_type LIKE ?', "#{base_string}" ) }
  scope :with_type_array, -> (base_array) {where('type_type IN (?)', base_array ) }

  scope :primary, -> {where(type_type: %w{neotype lectotype holotype}).order('biological_object_id')}
  scope :syntypes, -> {where(type_type: %w{syntype syntypes}).order('biological_object_id')}
  scope :primary_with_protonym_array, -> (base_array) {select('type_type, source_id, biological_object_id').group('type_type, source_id, biological_object_id').where("type_materials.type_type IN ('neotype', 'lectotype', 'holotype', 'syntype', 'syntypes') AND type_materials.protonym_id IN (?)", base_array ) }

  soft_validate(:sv_single_primary_type, set: :single_primary_type)
  soft_validate(:sv_type_source, set: :type_source)

  validates :protonym, presence: true
  validates :material, presence: true
  validates_presence_of :type_type

  validate :check_type_type

  def type_source
    if !!self.source_id
      self.source
    elsif !!self.protonym
      if !!self.protonym.source_id
        self.protonym.source
      else
        nil
      end
    else
      nil
    end
  end

  def self.find_for_autocomplete(params)
    term = params[:term]
    include(:protonym, :material, :source).
        where(protonyms: {id: term}, collection_objects: {id: term}, sources: {id: term})
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
        errors.add(:protonym_id, 'Type cannot be designated for a not species group taxon')
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
    soft_validations.add(:source_id, 'Source is not selected neither for type nor for taxon') unless !!self.type_source
  end

  #endregion
end
