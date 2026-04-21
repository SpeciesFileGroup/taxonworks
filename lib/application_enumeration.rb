# Not needed in zeitwerk
# Dir[Rails.root.to_s + '/app/models/*.rb'].each { |file| require_dependency file }

# Methods for enumerating models, tables, columns etc.
#
# !! If you think that a method belongs here chances are it already exists in a Rails extension.
#
# Note the use of Module.nesting (http://urbanautomaton.com/blog/2013/08/27/rails-autoloading-hell/)
#
module ApplicationEnumeration

  # TODO: This should be a require check likely, for lib/taxon_works.rb or some such
  # Rails.application.eager_load! if ActiveRecord::Base.connected?

  # @param target [Instance of an ApplicationRecord model]
  # @return [Array of Symbol]
  #   a list attributes except "id", 'md5_", and postfixed  "_id", "_at"
  #   This is an arbitrary convention, wrap this to further refine.
  def self.attributes(target)
     target.attributes.select{|k,v| !(k =~ /\Amd5_|_id\z|\Aid\z|_at\z/)}.symbolize_keys.keys.sort
  end

  # @return [Array]
  #   a list symbols that represent populated, non "cached", non "_id", non reserved attributes
  def self.alternate_value_attributes(object)
    if object.class::ALTERNATE_VALUES_FOR.blank?
      raise("#{object.class} attempted to annotate a class without ALTERNATE_VALUES_FOR -  please inform the programmers")
    else
      object.attributes.select{|k,v| v.present? && object.class::ALTERNATE_VALUES_FOR.include?(k.to_sym)}.keys.map(&:to_sym)
    end
  end

  # @param [Object] object
  # @return [Array of Symbols]
  #   a whitelist of the attributes of a given instance that may be annotated
  # !! Some models have blacklists (e.g. Serial)
  def self.annotatable_attributes(object)
    object.attributes.select{|k,v| v.present? && !(k =~ /.*_id\z|cached_*.*/)}.keys.map(&:to_sym) - ( RESERVED_ATTRIBUTES - [:parent_id])
  end

  # @return [Array]
  #   all models that inherit directly from ApplicationRecord
  def self.superclass_models
    ApplicationRecord.descendants.select{|a| a.superclass == ApplicationRecord }
  end

  # @return [Array of Classes]
  #   all models with a project_id attribute
  def self.project_data_classes
    superclass_models.select{|a| a.column_names.include?('project_id') }
  end

  # @return [Array of Classes]
  #   data models that do not have a project_id attribute
  def self.non_project_data_classes
    data_models - project_data_classes
  end

  # @return [Array]
  #   all superclass models that are community/shared
  def self.community_data_classes
    superclass_models.select{|a| a < Shared::SharedAcrossProjects }
  end

  # @return [Array]
  #   all superclass data models
  def self.data_models
    superclass_models.select{|a| a < Shared::IsData}
  end

  # @return [Array]
  #   all superclass data models
  def self.community_models
    superclass_models.select{|a| a < Shared::SharedAcrossProjects}
  end

  # !! See the built in self.descendants for actual inheritance tracking, this is path based.
  # @param [Object] klass
  # @return  [Array of Classes]
  #   all models in the /app/models/#{klass.name} (not necessarily inheriting)
  # Used in Ranks.
  def self.all_submodels(klass)
    Dir.glob(Rails.root + "app/models/#{klass.name.underscore}/**/*.rb").collect{|a| self.model_from_file_name(a) }
  end

  # @param [String] file_name
  # @return [Class]
  #   represented by a path included filename from /app/models.
  # e.g. given 'app/models/specimen.rb' the Specimen class is returned
  def self.model_from_file_name(file_name)
    file_name.split(/app\/models\//).last[0..-4].split(/\\/).collect{|b| b.camelize}.join('::').safe_constantize
  end

  # @param [Object] parent
  # @return [Hash]
  def self.nested_subclasses(parent = self)
    parent.subclasses.inject({}) { | hsh, subclass |
      hsh.merge!(subclass.name => nested_subclasses(subclass))
    }
  end

  # @return Array of AR associations
  def self.klass_reflections(klass, relationship_type = :all)
    relationship_types = relationship_type == :all ?
      [:belongs_to, :has_one, :has_many] : [relationship_type]

    a = []
    relationship_types.each do |t|
      a += klass.reflect_on_all_associations(t).sort{ |a, b|
        a.name <=> b.name
      }
    end

    a
  end

  def self.relation_targets_community?(relation)
    case relationship_type(relation)
    when :has_many
      relation.class_name.safe_constantize.is_community?
    when :has_one
      raise TaxonWorks::Error, "Has one support not implemented in unify, throw eggs at the devs."
    when :belongs_to
      if k = relation.options[:class_name]
        k.safe_constantize.is_community?
      else
        raise TaxonWorks::Error, "Missing attribute class_name on #{relation.name}."
      end
    end
  end

  # collection?, has_mone?  belongs_to?
  def self.relationship_type(relation)
    if relation.collection? # class.name.match('HasMany')
      return :has_many
    elsif relation.has_one? # class.name.match('HasOne')
      return :has_one
    elsif relation.belongs_to? # class.name.match('BelongsTo')
      return :belongs_to
    end

    raise TaxonWorks::Error, "Unknown relationship type for #{relation.name}."
  end

  def self.citable_relations(klass, relationship_type = :all)
    types = relationship_type == :all ?
      [:has_many, :has_one, :belongs_to] : [relationship_type]

    h = {}

    types.each do |t|
      h[t] = klass.reflect_on_all_associations(t).filter_map do |r|
        if r.klass.ancestors.include?(Shared::Citations)
          if t == :has_many
            r.plural_name.to_sym
          else
            r.name.to_sym
          end
        else
          nil
        end
      end
    end

    h
  end

  # TODO: DRY with Unify::EXCLUDE_RELATIONS
  EXCLUDE_RELATIONS_FOR_RELATED_DATA = [
    :versions,
    :dwc_occurrence,
    :pinboard_items,
    :cached_map_register,
    :cached_map_items,
    :cached_maps
  ].freeze

  # @param object [ApplicationRecord]
  # @param ignore [Array<Symbol>] additional relation names to ignore
  # @return [Boolean]
  #   true if object has no data in any has_many or has_one associations
  #   Excludes `through` associations and cached/computed relations.
  def self.no_related_data?(object, ignore: [])
    excluded = EXCLUDE_RELATIONS_FOR_RELATED_DATA + ignore

    (klass_reflections(object.class, :has_many) + klass_reflections(object.class, :has_one)).each do |relation|
      next if relation.options[:through].present?
      next if excluded.include?(relation.name)
      next if relation.options[:foreign_key]&.match?(/cache/)

      related = object.send(relation.name)

      has_data = if relation.collection?
                   related.any?
                 else
                   related.present?
                 end

      return false if has_data
    end

    true
  end


  # Filter out STI subclass relations that are redundant with their parent class
  # (e.g., `protonym` belongs_to duplicates `taxon_name` belongs_to).
  # A subclass relation is only dropped when the parent association has no scope
  # - an unscoped parent always covers all records the subclass relation would
  # return.
  #
  # !! There's no general way to compare scoped STI relations, so this method
  # does *not* filter out STI relations when the parent relation is scoped. !!
  # TODO: maybe we return a separate list of those if any occur.
  #
  # @param klass [Class] an ActiveRecord model class
  # @param relation_names [Array<Symbol>]
  # @return [Hash] { relation_name => reflection }
  def self.filter_sti_relations(klass, relation_names)
    reflections =
      relation_names.map { |name| [name, klass.reflect_on_association(name)] }.to_h

    filtered_names = relation_names.reject do |relation_name|
      reflection = reflections[relation_name]
      next false if reflection.nil? || reflection.options[:polymorphic]

      # Drop this relation if its class is a subclass of an unscoped parent relation,
      # or if it has the same class but is scoped while the other is not.
      reflections.any? do |other_name, other_reflection|
        next false if relation_name == other_name
        next false if other_reflection.nil? || other_reflection.options[:polymorphic]
        next false unless other_reflection.scope.nil?
        reflection.klass < other_reflection.klass ||
          (reflection.klass == other_reflection.klass && reflection.scope.present?)
      end
    end

    reflections.slice(*filtered_names)
  end

end
