# A collection profile, extensible, but currently sensu INHS/Colin Favret.
# See Favret, C., et al. "Profiling natural history collections: A method for quantitative and comparative health assessment."
# Collection Forum. Vol. 22. No. 1-2. 2007.
#
# Data is validated against a .yml definition in config/initializers/constants/data/collection_profile_indices.yml
# That file is loaded to COLLECTION_PROFILE_INDICES[:Favret][:dry][:conservation_status][1]
#
# @!attribute container_id
#   @return [Integer]
#      the (physical) Container beign profiled
#
# @!attribute otu_id
#   @return [Integer]
#     the encompassing taxon found in this container
#
# @!attribute conservation_status
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute processing_state
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute container_condition
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute condition_of_labels
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute identification_level
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute arrangement_level
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute data_quality
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute computerization_level
#   @return [Integer]
#    See Favret et al. (2007) (cited above)
#
# @!attribute number_of_collection_objects
#   @return [Integer]
#     a count of the number of collection objects in this container (asserted, not as calculated in TW)
#
# @!attribute number_of_containers
#   @return [Integer]
#     a count of the number of containers inside this container (asserted, not as calculated in TW)
#
# @!attribute project_id
#   @return [Integer]
#     the Project ID
#
# @!attribute collection_type
#   @return [String]
#     one of 'wet', 'dry', 'slide' sensu Favret.  Model is extensible via editing .yml and new profile types.
#
class CollectionProfile < ApplicationRecord
  include Housekeeping
  include SoftValidation
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData

  belongs_to :container, inverse_of: :collection_profiles
  belongs_to :otu

  # Once created the intent is that CollectionProfiles are #dup(ed), not
  # edited.  If there was a data error pass true here
  attr_accessor :force_update

  scope :with_collection_type_string, -> (type_string) {where(collection_type: type_string)}
  scope :with_container_id, -> (container) {where(container_id: container)}
  scope :with_otu_id, -> (otu) {where(otu_id: otu)}

  validates :conservation_status,
            :processing_state,
            :container_condition,
            :condition_of_labels,
            :identification_level,
            :arrangement_level,
            :data_quality,
            :computerization_level,
            :collection_type, presence: true

  validate :validate_type,
           :validate_number,
           :validate_indices

  validate :prevent_editing, unless: -> {self.force_update}

  # region Profile indices

  # @return [Array]
  #   set of all provided indecies, if any is not provided return an empty array
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

  # @return [Float, nil]
  #    the average of all 8 indecies
  def average_profile_index
    i = self.collection_profile_indices
    i.empty? ? nil : i.sum / i.size.to_f
  end

  #endregion

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

      COLLECTION_PROFILE_INDICES[:Favret][ct].each_key do |a|
        v = self.send(a)
        unless v.nil?
          errors.add(a.to_sym, 'Invalid entry') if COLLECTION_PROFILE_INDICES[:Favret][ct][a.to_sym][v].nil?
        end
      end
    end
  end

  def prevent_editing
    unless self.new_record? || (self.created_at == self.updated_at) # a little strange, handles Factories?!
      errors.add(:base, 'Collection profile should not be updated. Updated version should be saved as a new record')
    end
  end

end
