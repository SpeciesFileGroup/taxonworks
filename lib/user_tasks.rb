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

  # A conviencience wrapper for handling user task related metadata 
  class UserTask
    attr_accessor :name, :prefix, :description, :related

    def initialize(data)
      raise "Improperly defined user task #{data} in user_tasks.yml." if data.nil? || data[0].nil? 
      attributes = data[1] 
      @prefix = data[0] 
      @name = attributes[:name]
      @description = attributes[:description]
      @related = attributes[:related]
    end

    def path
      "#{@prefix}_path"
    end

    def url
      "#{@prefix}_url"
    end
  end

  TASK_DATA = YAML.load_file(Rails.root + 'config/interface/user_tasks.yml') 
  TASKS = TASK_DATA.collect{|td| UserTask.new(td) } 

end


