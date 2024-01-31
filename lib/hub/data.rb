module Hub::Data

  # A convenience wrapper for handling user task related metadata.
  class Data

    # @return [String, nil]
    #   the class/model name
    attr_accessor :name

    # @return [String]
    #   one of [complete, stable, prototype, unknown (default) ] (see user_tasks.yml)
    attr_accessor :status

    # @return [Array]
    #   the iconizable categories this task applies to (see yaml)
    attr_accessor :categories

    # @return [Boolean]
    #  true (default) if this task should be linked to from the hub
    attr_accessor :hide

    # @return [Boolean]
    #   the section classification (core, etc.)
    attr_accessor :section

    # @return [String]
    #   the help description describing this class # TODO- reconcile vs. model descriptions/documentation elsewhere
    attr_accessor :description

    # @return [Array]
    #    related (by model name) models
    attr_accessor :related_models

    # @return [Boolean]
    #   the klass of the model
    attr_accessor :klass

    attr_accessor :shared

    attr_accessor :application_defined

    # @param [Hash] args
    def initialize(klass, attributes)
      attributes ||= {}
      raise "Improperly defined user task #{data} in user_tasks.yml." if klass.nil?
      @klass = klass.constantize
      @name = klass.tableize.humanize
      @description = attributes['description']
      @hide = (attributes['hide'] ? true : false)
      @status = attributes['status']
      @categories = attributes['categories']
      @section = attributes['section']
      @shared = attributes['shared']
      @application_defined = attributes['application_defined']
      @related_models = attributes['related_models']
    end

    # @return [String]
    def status
      @status.nil? ? 'unknown' : @status
    end

    # @return [Array]
    def categories
      @categories.nil? ? [] : @categories
    end

    # @return [Array]
    def related_models
      @related_models.nil? ? [] : @related_models
    end

    # @return [nil, String]
    def shared_css
      shared.nil? ? nil : 'shared'
    end

    # @return [nil, String]
    def application_css
      application_defined.nil? ? nil : 'application_defined'
    end

    # @return [String]
    def combined_css
      [shared_css, application_css].compact.join(' ')
    end

  end

  # The raw YAML (Hash)
  CONFIG_DATA = YAML.load_file(Rails.root + 'config/interface/hub/data.yml')

  SECTIONS = CONFIG_DATA.keys

  data = {}
  by_name = {}

  # rubocop:disable Style/StringHashKeys
  SECTIONS.each do |s|
    data[s] = []
    CONFIG_DATA[s].each_key do |d|
      a = CONFIG_DATA[s][d] || {}
      n = Data.new(d, a.merge('section' => s))
      data[s].push(n)
      by_name[d] = n
    end
  end
  # rubocop:enable Style/StringHashKeys

  # A Hash of prefix => UserTasks::UserTask
  INDEX = data
  BY_NAME = by_name

  # @param [String] section
  # @return [Object]
  def self.items_for(section)
    INDEX[section]
  end

  # @param [String] section
  # @return [Array]
  def self.visual_items_for(section)
    INDEX[section].select{|a| !a.hide}.sort_by(&:name)
  end

  # @param [String] prefix
  # @return [String]
  #   translate a related prefix into a name string if present, else return the string as is
  def self.related_name(prefix)
    if t = INDEXED_TASKS[prefix]
      t.name
    else
      prefix
    end
  end

  # @param [String] prefix
  # @return [Object]
  def self.related_routes(prefix)
    INDEXED_TASKS[prefix].related
  end

end


