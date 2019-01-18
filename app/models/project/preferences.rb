class Project 
  module Preferences 

#   DEFAULT_WORKBENCH_STARTING_PATH = '/hub'.freeze
#   DEFAULT_WORKBENCH_SETTINGS = {
#     'workbench_starting_path' => DEFAULT_WORKBENCH_STARTING_PATH
#   }.freeze

    BASE_PREFERENCES = YAML.load_file(Rails.root + 'config/preferences/project.yml')

    Project.class_eval do
      store :preferences, accessors: BASE_PREFERENCES.symbolize_keys.keys, coder: JSON
      before_save :fill_preferences 

  # after_initialize :set_default_preferences

      def self.hash_preferences
        Project::BASE_PREFERENCES.select{|k, v| Project::BASE_PREFERENCES[k].kind_of?(Hash)}.keys.inject({}){|hsh,k| hsh.merge!(k.to_sym => {})} 
      end

      def self.array_preferences
        Project::BASE_PREFERENCES.select{|k, v| Project::BASE_PREFERENCES[k].kind_of?(Array)}.keys.inject({}){|hsh,k| hsh.merge!(k.to_sym => [])} 
      end

      def self.key_value_preferences
        Project::BASE_PREFERENCES.symbolize_keys.keys.select{|k| Project::BASE_PREFERENCES[k] != {} && Project::BASE_PREFERENCES[k] != []}
      end
    end



    def fill_preferences
      if preferences.empty?
        reset_preferences
      else
        Project::BASE_PREFERENCES.keys.each do |k|
          preferences[k] = Project::BASE_PREFERENCES[k] if send(k).nil?
        end
      end
      true
    end

    def reset_preferences
      write_attribute(:preferences, Project::BASE_PREFERENCES)
    end

    def layout=(values)
      l = layout.nil? ? {} : layout
      super(l.merge(values))
    end

  # def set_default_preferences
  #   write_attribute(:preferences, DEFAULT_WORKBENCH_SETTINGS.merge(preferences ||= {}) )
  # end

    #  def clear_preferences
    #    update_column(:preferences, DEFAULT_WORKBENCH_SETTINGS)
    #  end

    
  end
end
