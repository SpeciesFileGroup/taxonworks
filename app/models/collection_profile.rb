# @!attribute collection_type 
#   @return String
#  "wet", "dry", or "slide"

class CollectionProfile < ActiveRecord::Base

  include Housekeeping
  include SoftValidation

  belongs_to :container
  belongs_to :otu

  scope :with_collection_type_string, -> (type_string) {where(collection_type: type_string)}
  scope :with_container_id, -> (container) {where(container_id: container) }                     #  better to not add order here .order('created_at DESC') }
  scope :with_otu_id, -> (otu) {where(otu_id: otu)  }                                           # .order('created_at DESC') }

  # Use shared scopes lib/housekeeping/timestamps for this
  scope :created_before_date, -> (date) { where('"collection_profiles"."id" in (SELECT DISTINCT ON (id) id FROM collection_profiles WHERE created_at < ? ORDER BY id, created_at DESC)', "#{date}")}

  validates :conservation_status,
            :processing_state,
            :container_condition,
            :condition_of_labels,
            :identification_level,
            :arrangement_level,
            :data_quality,
            :computerization_level,
            :collection_type,
            presence: true

  before_validation :validate_type,
    :validate_number,
    :validate_indices,
    :validate_date


  # COLLECTION_PROFILE_INDICES[:Favret][:dry][:conservation_status][1] - see config/initializers/collection_profile.rb for indices

  #region Profile indices

  def collection_profile_indices
    i = [self.conservation_status,
         self.processing_state,
         self.container_condition,
         self.condition_of_labels,
         self.identification_level,
         self.arrangement_level,
         self.data_quality,
         self.computerization_level].compact
    i.size == 8 ? i : []
  end

  def average_profile_index
    i = self.collection_profile_indices
    i.empty? ? nil : i.sum / i.size.to_f
  end

  #endregion

  #region Validation

  private

  def validate_type
    unless self.collection_type.blank?
      errors.add(:collection_type, 'Invalid profile type') if COLLECTION_PROFILE_INDICES[:Favret][self.collection_type.to_sym].nil?
    end
  end

  def validate_number
    t = self.collection_type.to_s
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
    unless self.collection_type.blank?
      ct = self.collection_type.to_sym
      unless self.conservation_status.blank?
        errors.add(:conservation_status, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:conservation_status][self.conservation_status].nil?
      end
      unless self.processing_state.blank?
        errors.add(:processing_state, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:processing_state][self.processing_state].nil?
      end
      unless self.container_condition.blank?
        errors.add(:container_condition, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:container_condition][self.container_condition].nil?
      end
      unless self.condition_of_labels.blank?
        errors.add(:condition_of_labels, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:condition_of_labels][self.condition_of_labels].nil?
      end
      unless self.identification_level.blank?
        errors.add(:identification_level, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:identification_level][self.identification_level].nil?
      end
      unless self.arrangement_level.blank?
        errors.add(:arrangement_level, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:arrangement_level][self.arrangement_level].nil?
      end
      unless self.data_quality.blank?
        errors.add(:data_quality, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:data_quality][self.data_quality].nil?
      end
      unless self.computerization_level.blank?
        errors.add(:computerization_level, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][:computerization_level][self.computerization_level].nil?
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
