# Concern for models that annotate BOTH project and community data
#
module Shared::DualAnnotator
  extend ActiveSupport::Concern
  
  ALWAYS_COMMUNITY = [ 'GeographicArea', 'Person', 'Serial', 'Source', 'Organization', 'Repository']
  
  included do
    
    before_save :force_community_check
    
    attr_accessor :is_community_annotation
    
    def is_community_annotation?
      always_community? ||  (is_community_annotation == true) || is_community_annotation.to_s == 'true'
    end
    
    # @return Boolean
    def always_community?
      
      case self.class.base_class.name
      when 'AlternateValue'
        if self.alternate_value_object_type =~ /#{self.class::ALWAYS_COMMUNITY.join('|')}/
          return true
        end
      when 'Identifier'
        if self.identifier_object_type =~ /#{self.class::ALWAYS_COMMUNITY.join('|')}/
          if ::Identifier::Global.descendants.map(&:name).include?(self.class.name)
            return true
          end
        end
      end
    end
    
    private
    
    # TODO: change presence of constant, this won't work
    def force_community_check
      write_attribute(:project_id, nil) if always_community?
      true
    end
  end
  
  module ClassMethods
  end
  
end
