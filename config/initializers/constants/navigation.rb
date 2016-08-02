require 'yaml'
RELATED_FOR_NAVIGATION = YAML.load_file(Rails.root + 'config/interface/related_hub_tab.yml').freeze
