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

    # @return [Boolean]
    #   the section classification (core, etc.)
    attr_accessor :klass

    attr_accessor :shared

    attr_accessor :application_defined

    def initialize(klass, attributes)
      attributes ||= {}
      raise "Improperly defined user task #{data} in user_tasks.yml." if klass.nil?
      @klass = klass.constantize
      @name = klass.tableize.humanize 
      @description = attributes['description']
      @hub = (attributes['hide'] ? true : false) 
      @status = attributes['status']
      @categories = attributes['categories']
      @section = attributes['section']
      @shared = attributes['shared']
      @application_defined = attributes['application_defined']
    end

    def status
      @status.nil? ? 'unknown' : @status
    end

    def categories
      @categories.nil? ? [] : @categories
    end

    def shared_css
      shared.nil? ? nil : 'shared'
    end

    def application_css
      application_defined.nil? ? nil : 'shared'
    end


  end

  # The raw YAML (Hash)
  CONFIG_DATA = YAML.load_file(Rails.root + 'config/interface/hub/data.yml') 
  
  SECTIONS = CONFIG_DATA.keys

  data = {}

  SECTIONS.each do |s| 
    data[s] = [] 
    CONFIG_DATA[s].keys.each do |d|
      a = CONFIG_DATA[s][d] || {}
      data[s].push( Data.new(d, a.merge('section' => s)))
    end
  end

  # A Hash of prefix => UserTasks::UserTask 
  INDEX = data 

  def self.items_for(section)
    INDEX[section]
  end

  # @return [String]
  #   translate a related prefix into a name string if present, else return the string as is
  def self.related_name(prefix)
    if t = INDEXED_TASKS[prefix]
      t.name
    else
      prefix
    end 
  end

  def self.related_routes(prefix)
    INDEXED_TASKS[prefix].related
  end

end


