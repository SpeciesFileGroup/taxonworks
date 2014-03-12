class CollectionProfile < ActiveRecord::Base

  include Housekeeping
  include SoftValidation

  belongs_to :container
  belongs_to :otu

  validates_presence_of :conservation_status, message: 'Conservation status is not selected'
  validates_presence_of :processing_state, message: 'Processing state is not selected'
  validates_presence_of :container_condition, message: 'Container condition is not selected'
  validates_presence_of :condition_of_labels, message: 'Condition of labels is not selected'
  validates_presence_of :identification_level, message: 'Identification level is not selected'
  validates_presence_of :arrangement_level, message: 'Arrangement level is not selected'
  validates_presence_of :data_quality, message: 'Data quality is not selected'
  validates_presence_of :computerization_level, message: 'Computerization_level is not selected'
  validates_presence_of :type, message: 'Type is not selected'

  before_validation :validate_type,
                    :validate_number,
                    :validate_indices,
                    :validate_date

  #region Profile indices

  COLLECTION_PROFILE_TYPES = %w(dry wet slide)

  def self.favret_conservation_status_indices(t)
    case t
      when 'dry'
        {1 => 'pest infestation or specimens unusable due to damage',
             2 => 'specimens damaged, pins broken or bent',
             3 => 'specimens intact and stable'}
      when 'slide'
        {1 => 'slide or cover is broken or mountant crystallized',
             2 => 'improper mounting medium, not ringed, slide or cover is cracked',
             3 => 'slide ringed or mounted in Canada balsam'}
      when 'wet'
        {1 => 'specimens damaged or desiccated (not completely covered by fluid)',
             2 => 'fluid level low or dark',
             3 =>'fluid topped off and clear'}
      else
        {}
    end
  end

  def self.favret_processing_state_indices(t)
    case t
      when 'dry'
        {1 => 'bulk, unprocessed specimens',
             2 => 'specimens lacking labels or not properly prepared',
             3 => 'properly sorted and labled'}
      when 'slide'
        {2 => 'specimens not cleared and/or improperly oriented',
             3 =>'specimens cleared and properly oriented'}
      when 'wet'
        {1 => 'bulk, unprocessed specimens',
             2 => 'mixed field samples in clear alcohol and proper vials',
             3 => 'properly sorted and labled'}
      else
        {}
    end
  end

  def self.favret_container_condition_indices(t)
    case t
      when 'dry'
        {1 => 'cigar boxes, pill boxes, paper bags',
             2 => 'substandard containers, hart botom unit trays',
             3 => 'wrong size or dirty unit trays',
             4 => 'archival unit trays'}
      when 'slide'
        {1 => 'not stored in slide box or tray',
             2 => 'slide boxes of non-standard 100-slide size, brocken or rusty hinges',
             3 => 'good slide boxes or trays with rust-free hinges and substantial closure clasps',
             4 => 'slides stored flat'}
      when 'wet'
        {1 => 'bad stoppers/lids, loose vails/jars; vials  loose on shelf',
             2 => 'degraded or poor stoppers/lids; vials in wire-sided racks',
             3 => 'neoprene stoppers, good containers; vial racks solid',
             4 => 'archival racks/trays, stoppers'}
      else
        {}
    end
  end

  def self.favret_condition_of_labels_indices(t)
    case t
      when 'dry'
        {1 => 'faded to illegible, crumbling or missing',
             2 => 'partially faded, on non-archival paper',
             3 => 'labels on archival paper'}
      when 'slide'
        {1 => 'faded to illegible, crumbling or missing, become detached',
             2 => 'partially faded or pencil writing, on non-archival paper',
             3 => 'labels on archival paper'}
      when 'wet'
        {1 => 'faded to illegible, crumbling or missing',
             2 => 'partially faded, on non-archival paper',
             3 => 'labels on archival paper'}
      else
        {}
    end
  end

  def self.favret_identification_level_indices(t)
    case
      when 'dry'
        {1 => 'all specimens not determined to any level',
             2 => 'identified to order or family',
             3 => 'identified to genus (in small groups to family)',
             4 => 'identified to species'}
      when 'slide'
        {1 => 'all specimens not determined to any level',
             2 => 'identified to order or family',
             3 => 'identified to genus (in small groups to family)',
             4 => 'identified to species'}
      when 'wet'
        {1 => 'all specimens not determined to any level',
             2 => 'identified to order or family',
             3 => 'identified to genus (in small groups to family)',
             4 => 'identified to species'}
      else
        {}
    end
  end

  def self.favret_arrangement_level_indices(t)
    case t
      when 'dry'
        {1 => 'mixed taxa in same container',
             2 => 'specimens crowded arranged at higher taxonomic level, or species sharing trays',
             3 => 'specimens arranged alphabetically or phylogenetically',
             4 => 'specimens arranged geographically or numerically within a taxon'}
      when 'slide'
        {1 => 'mixed taxa in same container',
             2 => 'specimens crowded arranged at higher taxonomic level, or species sharing trays',
             3 => 'specimens arranged alphabetically or phylogenetically',
             4 => 'specimens arranged geographically or numerically within a taxon'}
      when 'wet'
        {1 => 'mixed taxa in same container',
             2 => 'specimens crowded arranged at higher taxonomic level, or species sharing trays',
             3 => 'specimens arranged alphabetically or phylogenetically',
             4 => 'specimens arranged geographically or numerically within a taxon'}
      else
        {}
    end
  end

  def self.favret_data_quality_indices(t)
    case t
      when 'dry'
        {1 => 'data absent often codes only',
             2 => 'missing data can be inferred',
             3 => 'all data fields intact',
             4 => 'value-added data, including retrospective georeferencing'}
      when 'slide'
        {1 => 'data absent often codes only',
             2 => 'missing data can be inferred',
             3 => 'all data fields intact',
             4 => 'value-added data, including retrospective georeferencing'}
      when 'wet'
        {1 => 'data absent often codes only',
             2 => 'missing data can be inferred',
             3 => 'all data fields intact',
             4 => 'value-added data, including retrospective georeferencing'}
      else
        {}
    end
  end

  def self.favret_computerization_level_indices(t)
    case t
      when 'dry'
        {2 => 'no computerization',
             3 => 'taxonomic information computerized',
             4 => 'all specimens databased and localities georeferenced'}
      when 'slide'
        {2 => 'no computerization',
             3 => 'taxonomic information computerized',
             4 => 'all specimens databased and localities georeferenced'}
      when 'wet'
        {2 => 'no computerization',
             3 => 'taxonomic information computerized',
             4 => 'all specimens databased and localities georeferenced'}
      else
        {}
    end
  end

  #endregion

  #region Validation

  def validate_type
    unless (self.type.blank? || COLLECTION_PROFILE_TYPES.include?(self.type.to_s))
      errors.add(:type, 'Invalid profile type')
    end
  end

  def validate_number
    t = self.type.to_s
    if self.number_of_collection_objects.nil? && self.number_of_containers.nil?
      errors.add(:number_of_collection_objects, 'At least one number of specimens or number of containers should be specified')
      errors.add(:number_of_containers, 'At least one number of specimens or number of containers should be specified')
    elsif t == 'dry' && self.number_of_collection_objects.nil?
      errors.add(:number_of_collection_objects, 'Number of specimens should be specified')
    elsif (t == 'wet' || t == 'slide') && self.number_of_containers.nil?
      errors.add(:number_of_containers, 'Number of slides or vials should be specified')
    end
  end

  def validate_indices
    unless self.type.blank?
      unless self.conservation_status.blank?
        errors.add(:conservation_status, 'Invalid entry') if CollectionProfile.favret_conservation_status_indices(self.type)[self.conservation_status].nil?
      end
      unless self.processing_state.blank?
        errors.add(:processing_state, 'Invalid entry') if CollectionProfile.favret_processing_state_indices(self.type)[self.processing_state].nil?
      end
      unless self.container_condition.blank?
        errors.add(:container_condition, 'Invalid entry') if CollectionProfile.favret_container_condition_indices(self.type)[self.container_condition].nil?
      end
      unless self.condition_of_labels.blank?
        errors.add(:condition_of_labels, 'Invalid entry') if CollectionProfile.favret_condition_of_labels_indices(self.type)[self.condition_of_labels].nil?
      end
      unless self.identification_level.blank?
        errors.add(:identification_level, 'Invalid entry') if CollectionProfile.favret_identification_level_indices(self.type)[self.identification_level].nil?
      end
      unless self.arrangement_level.blank?
        errors.add(:arrangement_level, 'Invalid entry') if CollectionProfile.favret_arrangement_level_indices(self.type)[self.arrangement_level].nil?
      end
      unless self.data_quality.blank?
        errors.add(:data_quality, 'Invalid entry') if CollectionProfile.favret_data_quality_indices(self.type)[self.data_quality].nil?
      end
      unless self.computerization_level.blank?
        errors.add(:computerization_level, 'Invalid entry') if CollectionProfile.favret_computerization_level_indices(self.type)[self.computerization_level].nil?
      end
    end
  end

  def validate_date
    unless self.created_at == self.updated_at
      errors.add(:updated_at, 'Collection profile should not be updated. Updated version should be saved as a new record')
    end
  end

  #endregion
end
