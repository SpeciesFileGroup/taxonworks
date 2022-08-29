# Concern for models that annotate BOTH project and community data
#
module Shared::DualAnnotator
  extend ActiveSupport::Concern

  ALWAYS_COMMUNITY = [ 'GeographicArea', 'Person', 'Serial', 'Source', 'Organization', 'Repository']

  included do

    before_save :force_community_check

    attr_accessor :is_community_annotation

    def is_community_annotation?
      (is_community_annotation == true) || is_community_annotation.to_s == 'true'
    end

    private

    # TODO: change presence of constant, this won't work
    def force_community_check
      nillify_project_id = false
      case self.class.base_class.name

      when 'AlternateValue'
        if self.alternate_value_object_type =~ /#{self.class::ALWAYS_COMMUNITY.join('|')}/
          nillify_project_id = true
        end
      when 'Identifier'
        if self.identifier_object_type =~ /#{self.class::ALWAYS_COMMUNITY.join('|')}/
          if ::Identifier::Global.descendants.map(&:name).include?(self.class.name)
            nillify_project_id = true
          end
        end
      end

      write_attribute(:project_id, nil) if nillify_project_id

      true
    end
  end

  module ClassMethods
  end

end
