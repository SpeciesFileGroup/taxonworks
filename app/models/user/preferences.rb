class User
  module Preferences

    BASE_PREFERENCES = YAML.load_file(Rails.root + 'config/preferences/user.yml')

    User.class_eval do
      store :preferences, accessors: BASE_PREFERENCES.symbolize_keys.keys, coder: JSON
      before_save :fill_preferences

      def self.hash_preferences
        User::BASE_PREFERENCES.select{|k, v| User::BASE_PREFERENCES[k].kind_of?(Hash)}.keys.inject({}){|hsh,k| hsh.merge!(k.to_sym => {})}
      end

      def self.array_preferences
        User::BASE_PREFERENCES.select{|k, v| User::BASE_PREFERENCES[k].kind_of?(Array)}.keys.inject({}){|hsh,k| hsh.merge!(k.to_sym => [])}
      end

      def self.key_value_preferences
        User::BASE_PREFERENCES.symbolize_keys.keys.select{|k| User::BASE_PREFERENCES[k] != {} && User::BASE_PREFERENCES[k] != []}
      end
    end

    def preferences
      prefs = read_attribute(:preferences)
      return prefs unless prefs.empty?

      write_attribute(:preferences, BASE_PREFERENCES)
      read_attribute(:preferences)
    end

    def fill_preferences
      if preferences.empty?
        reset_preferences
      else
        BASE_PREFERENCES.keys.each do |k|
          preferences[k] = BASE_PREFERENCES[k] if send(k).nil?
        end
      end
      true
    end

    def reset_preferences
      write_attribute(:preferences, BASE_PREFERENCES)
    end

    def reset_hub_favorites(project_id = nil)
      if project_id.nil?
        write_attribute(:hub_favorites, {})
      else
        h = read_attribute(:hub_favorites)
        h[project_id] = User::HUB_FAVORITES
        write_attribute(:hub_favorites, h)
      end
    end

    def layout=(values)
      l = layout.nil? ? {} : layout
      super(l.merge(values))
    end
  end
end
