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
  #   to access the related class use `.klass`
  def self.klass_reflections(klass, relationship_type = :has_many)
    a = klass.reflect_on_all_associations(relationship_type).sort{ |a, b| a.name <=> b.name }
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


end
