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
    include Navigation
    include Metamorphosize
    include HasRoles
    include Shared::Verifiers
    include Shared::Unify
    include Shared::Permissions
  end

  module ClassMethods

    # @return [Boolean]
    def is_community?
      self < Shared::SharedAcrossProjects ? true : false
    end

    def is_containable?
      self < Shared::Containable
    end

    def dwc_occurrence_eligible?
      self < Shared::IsDwcOccurrence
    end

    def is_observable?
      self < Shared::Observations
    end

    def is_distribution_assertable?
      self < Shared::AssertedDistributions
    end

    def is_biologically_relatable?
      self < Shared::BiologicalAssociations
    end

    def auto_uuids?
      self < Shared::AutoUuid
    end

    # @return [Array of String]
    #   only the non-cached and non-housekeeping column names
    def core_attributes # was data_attributes
      column_names.reject { |c| %w{id project_id created_by_id updated_by_id created_at updated_at}
        .include?(c) || c =~ /^cached/ }
    end

    # @return [Boolean]
    #   use update vs. a set of ids, but require the update to pass for all or none
    def batch_update_attribute(ids: [], attribute: nil, value: nil)
      return false if ids.empty? || attribute.nil? || value.nil?
      begin
        self.transaction do
          self.where(id: ids).each do |li|
            li.update(attribute => value)
          end
        end
      rescue
        return false
      end
      true
    end

=begin
---------------------------
             1   2   3   4       s returned for similar
---------------------------
1    |abc |  C   s   si  s       i returned for identical
---------------------------
2    |abcd|  s   C   s   s       C returned if class method, identical or similar
---------------------------
3    |abc |  si  s   C   s
---------------------------
4    | bc |              C
---------------------------
=end

    # @param [Hash] attr of matchable attributes
    # @return [Scope]
    def similar(attr)
      klass = self
      attr  = Stripper.strip_similar_attributes(klass, attr)
      attr  = attr.select { |_kee, val| val.present? }

      scope = klass.where(attr)
      scope
    end

    # @param [Hash] attr of matchable attributes
    # @return [Scope]
    def identical(attr)
      klass = self
      attr  = Stripper.strip_identical_attributes(klass, attr)

      scope = klass.where(attr) #.where.not(id:)
      scope
    end

    # @return Hash
    #  { restrict: {}, destroy: {} }
    #
    #  Summarizes the count of records that will be destroyed if these ids are destroyed, or records that
    #  will prevent destruction.
    def related_summary(ids)
      h = { restrict: {}, destroy: {} }
      objects = self.where(id: ids)

      base = self.table_name.to_sym

      [ self.reflect_on_all_associations(:has_many),
        self.reflect_on_all_associations(:has_one)
      ].each do |rt|

        rt.each do |r|
          d = r.options.dig(:dependent)
          next if d.nil?

          c = nil
          if r.type
            c =  r.klass.where(r.type.to_sym =>  self.name, r.type.gsub('_type', '_id').to_sym => objects.map(&:id)).count
          else
            c = r.klass.where(r.foreign_key.to_sym => objects.map(&:id)).count
          end

          if c > 0
            case d
            when :destroy
              h[:destroy][r.name] = c
            when :restrict_with_error
              h[:restrict][r.name] = c
            end
          end
        end
      end
      h
    end

    private

    # @return Array of IDs for this class
    #
    #  Make cutoff smaller to reach higher ids.
    #  Useful for pseudo-benchmarking.
    #  TODO: doesn't return total. There are some
    #  nice discussions on stack overflow.
    #  TODO: probably doesn't belong here
    def random_ids(total = 100)
      return self.none if total.blank?
      if column_names.include?('type')
        self.find_by_sql( "select id, type from #{self.table_name} where type = '#{self.name}' AND  random() < 0.0001 limit #{total};").pluck(:id)
      else
        self.find_by_sql( "select id from #{self.table_name} where random() < 0.0001 limit #{total};").pluck(:id)
      end
    end

  end  # END CLASS METHODS

  # @return [Boolean]
  # @params exclude [Array]
  #   of symbols
  # @params only [Array]
  #   of symbols
  # !! provide only exclude or only
  def is_in_use?(exclude = [], only = [])
    if only.empty?
      self.class.reflect_on_all_associations(:has_many).each do |r|
        next if exclude.include?(r.name)
        return true if self.send(r.name).count(:all) > 0
      end

      self.class.reflect_on_all_associations(:has_one).each do |r|
        next if exclude.include?(r.name)
        return true if self.send(r.name).count(:all) > 0
      end
    else
      only.each do |r|
        return true if self.send(r.to_s).count(:all) > 0
      end
    end

    false
  end

  # @return [Boolean]
  def is_community?
    self.class < Shared::SharedAcrossProjects ? true : false
  end

  # @param [Symbol] keys
  # @return [Hash]
  def errors_excepting(*keys)
    valid?
    keys.each do |k|
      errors.delete(k)
    end
    errors
  end

  # @return [Scope]
  def similar
    klass = self.class
    attr  = Stripper.strip_similar_attributes(klass, attributes)
    # matching only those attributes from the instance which are not empty
    attr = attr.select{ |_kee, val| val.present? }
    if id
      scope = klass.where(attr).not_self(self)
    else
      scope = klass.where(attr)
    end
    scope
  end

  # @return [Scope]
  def identical
    klass = self.class
    attr  = Stripper.strip_identical_attributes(klass, attributes)
    if id
      scope = klass.where(attr).not_self(self)
    else
      scope = klass.where(attr)
    end
    scope
  end

  # TODO: Doesn't belong here
  # @param [Symbol] keys
  # @return [Array]
  def full_error_messages_excepting(*keys)
    errors_excepting(*keys).full_messages
  end

end
