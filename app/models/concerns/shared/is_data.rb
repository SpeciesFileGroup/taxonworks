# Shared code for a classes that are "data" sensu TaxonWorks (things like Projects, users, and preferences are not data).
#
module Shared::IsData

  extend ActiveSupport::Concern

  included do
    include Pinnable
    include Levenshtein
  end

  def metamorphosize
    return self if self.class.descends_from_active_record?
    self.becomes(self.class.base_class)
  end

  # Determines whether the instance can be annotated
  # in one of the following ways
  def has_alternate_values?
    self.class < Shared::AlternateValues ? true : false
  end

  def has_citations?
    self.class < Shared::Citable ? true : false
  end

  def has_data_attributes?
    self.class < Shared::DataAttributes ? true : false
  end

  def has_identifiers?
    self.class < Shared::Identifiable ? true : false
  end

  def has_notes?
    self.class < Shared::Notable ? true : false
  end

  def has_tags?
    self.class < Shared::Taggable ? true : false
  end

  def has_confidences?
    self.class < Shared::Confidence ? true : false
  end

  def has_depictions?
    self.class < Shared::Depictions ? true : false
  end

  def is_loanable? 
    self.class < Shared::Loanable ? true : false
  end
  
  def has_protocols?
    self.class < Shared::Protocols ? true : false
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

  def is_community?
    self.class < Shared::SharedAcrossProjects ? true : false
  end

  # @return [#annotations_hash]
  # an accessor for the annotations_hash, overwritten by some inheriting classes
  def annotations
    annotations_hash
  end

  def errors_excepting(*keys)
    self.valid?
    keys.each do |k|
      self.errors.delete(k)
    end
    self.errors
  end

  def full_error_messages_excepting(*keys)
    errors_excepting(*keys).full_messages
  end

  module ClassMethods

    def is_community?
      self < Shared::SharedAcrossProjects ? true : false
    end

    # @return [Boolean]
    # true if model is an "annotator" (e.g. identifiers, tags, notes, data attributes, alternate values, citations), i.e. data that references another data element through STI
    def annotates?
      self.respond_to?(:annotated_object)
    end

    # @return [Scope]
    # a where clause that excludes the present object from being selected
    def not_self(object)
      if object.nil? || object.id.blank?
        where(object.class.table_name => {id: '<> 0'})
      else
        where(object.class.arel_table[:id].not_eq(object.to_param))
      end
    end

    # @return [Scope]
    # @params [List of ids or list of AR instances]
    #   a where clause that excludes the records with id = ids 
    # ! Not built for collisions
    def not_ids(*ids)
      where.not(id: ids)
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

  protected

  # @return [Hash]
  # Contains all "annotations" for this instance
  def annotations_hash
    result = {}
    result['citations'] = self.citations if self.has_citations? && self.citations.any?
    result['data attributes'] = self.data_attributes if self.has_data_attributes? && self.data_attributes.any?
    result['identifiers'] = self.identifiers if self.has_identifiers? && self.identifiers.any?
    result['notes'] = self.notes if self.has_notes? && self.notes.any?
    result['tags'] = self.tags if self.has_tags? && self.tags.any?

    result['depictions'] = self.depictions.order('depictions.position') if self.has_depictions? && self.depictions.any?
    result['confidences'] = self.confidences if self.has_confidences? && self.confidences.any?
    result['protocols'] = self.protocols if self.has_protocols? && self.protocols.any?
    result['alternate values'] = self.alternate_values if self.has_alternate_values? && self.alternate_values.any?
    result
  end

end
