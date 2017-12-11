# Shared code for a classes that are "data" sensu TaxonWorks (things like Projects, users, and preferences are not data).
# 
# !! This module must in included last !!
#
module Shared::IsData

  extend ActiveSupport::Concern

  included do
    include Pinnable
    include Levenshtein
    include Annotation
    include Scopes
  end

  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end

  def is_community?
    self.class < Shared::SharedAcrossProjects ? true : false
  end

  def is_in_use?
    self.class.reflect_on_all_associations(:has_many).each do |r|
      return true if self.send(r.name).count > 0
    end

    self.class.reflect_on_all_associations(:has_one).each do |r|
      return true if self.send(r.name).count > 0
    end

    false
  end

  def errors_excepting(*keys)
    valid?
    keys.each do |k|
      errors.delete(k)
    end
    errors
  end

  def full_error_messages_excepting(*keys)
    errors_excepting(*keys).full_messages
  end

  module ClassMethods

    def is_community?
      self < Shared::SharedAcrossProjects ? true : false
    end

    # @return [Boolean]
    #   use update vs. a set of ids, but require the update to pass for all or none
    def batch_update_attribute(ids: [], attribute: nil, value: nil)
      return false if ids.empty? || attribute.nil? || value.nil? 
      begin
        self.transaction do 
          self.where(id: ids).find_each do |li|
            li.update(attribute => value)
          end
        end
      rescue
        return false
      end
      true
    end
  end

end
