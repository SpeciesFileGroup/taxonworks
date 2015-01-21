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
#
module UserTasks
  
  TASKS = YAML.load_file(Rails.root + 'config/interface/user_tasks.yml') 

end
