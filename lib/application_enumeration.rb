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

  def self.citable_relations(klass, relationship_type = :all)
    types = relationship_type == :all ?
      [:has_many, :has_one, :belongs_to] : [relationship_type]

    h = {}

    types.each do |t|
      h[t] = klass.reflect_on_all_associations(t).filter_map do |r|
        if r.klass.ancestors.include?(Shared::Citations)
          # TODO: add the info we need for each type to get back to a klass id
          if t == :has_many
            #r.plural_name.to_sym
            "#{t}: #{r.name.to_sym}"
          else
            "#{t}: #{r.name.to_sym}"
          end
        else
          nil
        end
      end
    end

    h
  end

  # @param klass [Class] the model class (e.g., Otu)
  # @param relationship_type [Symbol] :all, :has_many, :has_one, or :belongs_to
  # @return [Hash] metadata for building joins from citations back to the source class
  #   Each entry contains:
  #   - relation_name: the association name
  #   - target_class: the class being cited
  #   - join_type: :direct, :through, or :polymorphic
  #   - join_details: hash with keys needed for building SQL joins
  def self.citable_relations_metadata(klass, relationship_type = :all)
    types = relationship_type == :all ?
      [:has_many, :has_one, :belongs_to] : [relationship_type]

    result = []

    types.each do |macro|
      klass.reflect_on_all_associations(macro).each do |reflection|
        # Only include relations where the target class includes Shared::Citations
        next unless reflection.klass.ancestors.include?(Shared::Citations)

        metadata = {
          relation_name: reflection.name,
          macro: macro,
          target_class: reflection.class_name
        }

        # Determine the join strategy
        if reflection.through_reflection
          # has_many :through relationship (e.g., images through depictions)
          through = klass.reflect_on_association(reflection.through_reflection.name)
          source = reflection.source_reflection

          metadata[:join_type] = :through
          metadata[:join_details] = {
            through_class: reflection.through_reflection.class_name,
            through_table: reflection.through_reflection.table_name,
            source_relation: source.name,
            # For the join from through table to source class
            source_foreign_key: source.foreign_key,
            source_foreign_type: source.polymorphic? ? source.foreign_type : nil,
            # For the join from klass to through table
            through_foreign_key: through.foreign_key,
            through_foreign_type: through.type # Will be nil if not polymorphic
          }
        elsif reflection.options[:as]
          # Polymorphic relationship (e.g., biological_associations as biological_association_subject)
          metadata[:join_type] = :polymorphic
          metadata[:join_details] = {
            foreign_key: reflection.foreign_key,
            foreign_type: reflection.type,
            as: reflection.options[:as]
          }
        else
          # Direct relationship
          if macro == :belongs_to
            # For belongs_to, the foreign key is in the source table (e.g., Otu.taxon_name_id)
            # We need to join from target back to source
            metadata[:join_type] = :belongs_to
            metadata[:join_details] = {
              foreign_key: reflection.foreign_key, # e.g., taxon_name_id
              primary_key: reflection.association_primary_key # e.g., id
            }
          else
            # For direct has_many, the foreign key is in the target table
            metadata[:join_type] = :direct
            metadata[:join_details] = {
              foreign_key: reflection.foreign_key
            }
          end
        end

        result << metadata
      end
    end

    result
  end


end
