require 'yaml'
DATA_RELATIONS_FOR_NAVIGATION = YAML.load_file(Rails.root + 'config/interface/data_relations_for_navigation.yml')
TASK_RELATIONS_FOR_NAVIGATION = YAML.load_file(Rails.root + 'config/interface/task_relations_for_navigation.yml')

