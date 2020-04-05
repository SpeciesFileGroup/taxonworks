# Within TaxonWorks (not Rails) a tasks
# is a bit of work that references 2
# or more data models at once, and that
# should be understandable without
# complicated context.  Tasks should
# typically do a single thing well, however
# complex forms (sensu single page apps)
# fall into this category as well.
#
# The UserTasks module provides developer
# support for tracking, testing, and integrating
# tasks.
#
module UserTasks

  CATEGORIES = %w{nomenclature source collection_object collecting_event biology matrix dna image}.freeze

  # A convenience wrapper for handling user task related metadata.
  class UserTask

    # @return [String, nil]
    #   the human readable, "friendly" name for this task.
    attr_accessor :name

    # @return [String]
    #   the Rails route prefix for the task
    attr_accessor :prefix

    # @return [String, nil]
    #   a full sentence or two describing to the user what this task does.
    attr_accessor  :description

    # @return [Array, nil]
    #   an array of Rails route prefixes that link to related tasks/functionality
    attr_accessor :related

    # @return [Boolean]
    #  true if this task should be linked to from the hub
    attr_accessor :hub

    # @return [Array]
    #   the iconizable categories this task applies to (see yaml)
    attr_accessor :categories

    # @return [String]
    #   the development status of the task (see yaml)
    attr_accessor :status

    # attr_reader :defaults

    # @param [Array] data
    def initialize(data)
      raise "Improperly defined user task #{data} in user_tasks.yml." if data.nil? || data[0].nil?
      attributes = data[1]
      @prefix = data[0]
      @name = attributes['name']
      @description = attributes['description']
      @related = attributes['related']
      @hub = (attributes['hub'] ? true : false)
      @status = attributes['status']
      @categories = attributes['categories']

     #route = Rails.application.routes.named_routes.get('update_serial_find_task')

     #@defaults = route.required_defaults
     #@defaults.merge!(verb: route.verb)
    end

    # @return [Array]
    def categories
      @categories.nil? ? [] : @categories
    end

    # @return [String]
    def status
      @status.nil? ? 'unknown' : @status
    end

    # @return [String]
    #   the name, or if not otherwise named, the prefix humanized
    def name
      return @name if @name
      prefix.humanize
    end

    # @return [String]
    #   the prefix with _path appended
    def path
      "#{prefix}_path"
    end

    # @return [String]
    #   the prefix with _url appended
    def url
      "#{prefix}_url"
    end

    # @return [Boolean]
    #   whether the route requires more than :action, :controller
    def requires_params?
      Rails.application.routes.named_routes.get(@prefix).required_keys.sort != [:action, :controller]
    end

    # @return [Hash]
    def to_h
      return {
        url_name: url,
        path_name: path,
        name: name,
        status: status,
        categories: categories,
        description: description,
        related: related,
        prefix: prefix,
        hub: hub
      }

    end
  end

  # The raw YAML (Hash)
  TASK_DATA = YAML.load_file(Rails.root + 'config/interface/hub/user_tasks.yml').freeze

  tasks = {}
  TASK_DATA.each do |td|
    tasks.merge!(td[0] => UserTask.new(td))
  end

  # A Hash of prefix => UserTasks::UserTask
  INDEXED_TASKS = tasks.freeze

  # @return [Array] of UserTasks::UserTask
  #    the UserTasks instances
  def self.tasks
    INDEXED_TASKS.values.sort!{|a, b| a.name <=> b.name }
  end

  # @return [Array] of UserTasks::UserTask
  #    the UserTasks instances that don't require parameters (i.e. can be linked to from anywhere)
  def self.parameter_free_tasks
    tasks.select{|t| !t.requires_params?}
  end

  # @return [Array] of UserTasks::UserTask
  #    the UserTasks instances that have @hub == true
  def self.hub_tasks(category = nil)
    a = tasks.select{|t| t.hub}
    return a if category.nil?
    return [] if !CATEGORIES.include?(category)
    a.select{|b| b.categories.include?(category) }
  end

  # @param [String] prefix
  #   A rails route prefix
  # @return [UserTasks::UserTask, nil]
  #    a instance of a UserTasks::UserTask
  def self.task(prefix)
    INDEXED_TASKS[prefix]
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
  # @return [UserTasks::UserTask, nil]
  def self.related_routes(prefix)
    INDEXED_TASKS[prefix].related
  end

end


