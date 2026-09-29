class Project
  module Coldp

    PREFERENCES_PATH = ['metadata', 'coldp'].freeze
    SETTINGS_PATH = ['metadata', 'coldp_settings'].freeze

    # @param metadata_yaml [String, nil]
    # @return [Array<String>]
    #   YAML syntax errors (empty when blank or parseable)
    def self.metadata_yaml_errors(metadata_yaml)
      return [] if metadata_yaml.blank?

      YAML.safe_load(metadata_yaml)
      []
    rescue Psych::SyntaxError => e
      [e.message]
    end

    # @return [Array]
    #   the array of COLDP profile hashes stored in preferences
    def coldp_profiles
      ensure_coldp_preferences_array!
      preferences.dig(*PREFERENCES_PATH)
    end

    # @param otu_id [Integer]
    # @return [Hash, nil]
    def coldp_profile_for(otu_id)
      coldp_profiles.detect { |p| p['otu_id'].to_i == otu_id.to_i }
    end

    # @param attrs [Hash]
    #   profile attributes including 'otu_id'
    # @return [Boolean]
    def create_coldp_profile(attrs)
      ensure_coldp_preferences_array!
      profiles = preferences.dig(*PREFERENCES_PATH)
      otu_id = attrs['otu_id'].to_i

      if profiles.any? { |p| p['otu_id'].to_i == otu_id }
        errors.add(:base, "A COLDP profile already exists for OTU #{otu_id}")
        return false
      end

      profiles << normalize_coldp_profile_attrs(attrs)

      save!
    rescue ActiveRecord::RecordInvalid, ArgumentError => e
      errors.add(:base, e.message)
      false
    end

    # @param attrs [Hash]
    #   profile attributes including 'otu_id'
    # @return [Boolean]
    def update_coldp_profile(attrs)
      ensure_coldp_preferences_array!
      profiles = preferences.dig(*PREFERENCES_PATH)
      otu_id = attrs['otu_id'].to_i

      existing_index = profiles.index { |p| p['otu_id'].to_i == otu_id }

      if existing_index.nil?
        errors.add(:base, "No COLDP profile found for OTU #{otu_id}")
        return false
      end

      profiles[existing_index] = normalize_coldp_profile_attrs(attrs)

      save!
    rescue ActiveRecord::RecordInvalid, ArgumentError => e
      errors.add(:base, e.message)
      false
    end

    # @param otu_id [Integer]
    # @return [Boolean]
    def destroy_coldp_profile(otu_id)
      ensure_coldp_preferences_array!
      profiles = preferences.dig(*PREFERENCES_PATH)
      profiles.reject! { |p| p['otu_id'].to_i == otu_id.to_i }
      save!
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    # @return [Hash]
    #   the COLDP settings hash stored in preferences
    def coldp_settings
      preferences.dig(*SETTINGS_PATH) || {}
    end

    # @param attrs [Hash]
    #   settings attributes to merge
    # @return [Boolean]
    def update_coldp_settings(attrs)
      prefs = preferences
      SETTINGS_PATH[0..-2].each do |key|
        prefs[key] = {} if prefs[key].nil?
        prefs = prefs[key]
      end
      prefs[SETTINGS_PATH.last] = {} unless prefs[SETTINGS_PATH.last].is_a?(Hash)
      prefs[SETTINGS_PATH.last].merge!(attrs)
      save!
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    # @return [Hash]
    #   preferences formatted for the Vue front-end
    def coldp_preferences_for_vue(user)
      {
        user_is_admin: user.is_project_administrator?(self),
        profiles: coldp_profiles,
        coldp_settings: coldp_settings,
        iri_map: ::Export::Coldp::Files::Taxon::IRI_MAP
      }
    end

    # @param otu_id [Integer]
    # @return [Integer]
    #   count of valid descendant taxon names that lack an OTU
    def coldp_missing_otus_count(otu_id)
      otu = Otu.where(project_id: id).find(otu_id)
      taxon_name = otu.taxon_name
      return 0 if taxon_name.nil?

      taxon_name.self_and_descendants.that_is_valid.without_otus.count
    end

    private

    def ensure_coldp_preferences_array!
      prefs = preferences
      path = PREFERENCES_PATH

      path[0..-2].each do |key|
        prefs[key] = {} if prefs[key].nil?
        prefs = prefs[key]
      end

      prefs[path.last] = [] if prefs[path.last].nil? || !prefs[path.last].is_a?(Array)
    end

    def normalize_coldp_profile_attrs(attrs)
      {
        'otu_id' => attrs['otu_id'].to_i,
        'checklistbank_dataset_id' => attrs['checklistbank_dataset_id'].presence&.to_i,
        'is_public' => attrs['is_public'] == true || attrs['is_public'] == 'true',
        'default_user_id' => attrs['default_user_id'].presence&.to_i,
        'max_age' => attrs['max_age'].presence ? Float(attrs['max_age']) : nil,
        'metadata_yaml' => attrs['metadata_yaml'].to_s,
        'maintain_metadata_in_checklistbank' => attrs['maintain_metadata_in_checklistbank'] == true || attrs['maintain_metadata_in_checklistbank'] == 'true',
        'base_url' => attrs['base_url'].to_s,
        'fossil_extinct' => attrs['fossil_extinct'] == true || attrs['fossil_extinct'] == 'true',
        'default_lifezone' => attrs['default_lifezone'].presence,
        'prefer_unlabelled_otus' => attrs.key?('prefer_unlabelled_otus') ?
          (attrs['prefer_unlabelled_otus'] == true || attrs['prefer_unlabelled_otus'] == 'true') :
          true
      }
    end

  end
end
