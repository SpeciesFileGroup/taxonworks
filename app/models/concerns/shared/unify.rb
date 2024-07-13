# Merge concepts
#   
#   When b merges to a the operation is: 
#     `complete` if b is left with no related data
#      `blocked` when merging is prevented by data validations
#
#
#  Difference b/w polymorphic and non-polymorphic objects
#
#  what about difference in values of the objects
#
#    
#  mode strict => absolutely no conflicting values
#
# TODO: 
#   - Annotation classes can not be merged
#   - write spec that ensures :inverse_of is seat for all necessary classes
#       Otu.first.merge_relations.collect{|r| [r.options[:inverse_of], r.name]} 
#       
#   - Pinboard items should be destroyed, and not cause failure 
#   - Mode that destroys invalid objects (e.g. global identifiers that can't be merged)
module Shared::Unify

  extend ActiveSupport::Concern

  # Used when batch iterating :all
  EXCLUDE_RELATIONS = [
    # all the housekeeping and project relations

    :versions,
    :dwc_occurrence_object # !? <- should be destroyed, not replaced
  ]

  # Alwyas include these, regardless of wether 
  # they are inferred
  INCLUDE_RELATIONS = [
    :roles
  ]

  included do
    attr_accessor :merge
  end

  # Iterating thorugh all of these
  def only_relations 
    []
  end

  # When merging skip these relations
  def except_relations
    []
  end

  def merge_relations
    if only_relations.any?
      only_relations  
    else
      used_inferred_relations - except_relations 
    end
  end

  # @return Array of symbols
  #   - or split to Polymorphic
  #
  # TODO: remove cached references, they should be computed     
  def inferred_relations
    (ApplicationEnumeration.klass_reflections(self.class) + 
     ApplicationEnumeration.klass_reflections(self.class, :has_one))
      .delete_if{|r| r.options[:foreign_key] =~ /cache/}
      .delete_if{|r| r.options[:through].present? || r.options[:class_name].present?}
    # .delete_if{|r| r.scope != nil && !INCLUDE_RELATIONS.include?(r.name)}

    # TODO: eliminate relations with * where clauses * 
    # - somehow remove exlcude relations here
  end

  # Remove nil.  
  # Keep seperated from inferred_relations so we can better audi all models in specs
  def used_inferred_relations
    inferred_relations.select{|r| !r.options[:inverse_of].nil?} 
  end

  # Methods to be called per Class before merge_relations are iterated
  #  TODO: use with super, cleanup pinboard items inside of transactionj<t_úX>
  def before_merge
    []
  end

  # Methods to be called per Class after merge_relations are iterated
  def after_merge
    []
  end

  # re-vist this concept remove is_data?
  # @return Boolean
  #   true - there is no FK or polymorphic reference to this object
  #        - this object is anot a blessed or special class record (e.g. a Root taxon name)
  def used?
  end

  # TODO: consider
  #   - a merge with preview = true wrapped in a transaction that you can roll back
  def mergeable?(remove_object)
    # !! Proxy 
    # Otu.first.merge_relations.collect{|r| [r.options[:inverse_of], r.name]} -> can have no nil in first position
    #   - if nil then assume it's cannonical form
    # TODO:
    #   - elimninate COMMUNITY data
    #   - maybe a class method Otu.new. ....   
    #   - Both belong to the same project
    #
  end

  # Unify is not the same as move.  For example we could move annotations
  # from one class of things to another, we can not do that here.
  # TODO: ensusure project level check is here
  def unify(remove_object, only: [], except: [], preview: false)
    s = {}

    o = remove_object

    if !is_community?
      if project_id != o.project_id
        s.merge!(
          failed: true, 
          message: 'missmatched projects')
        return s
      end
    end

    if o.class.base_class.name != self.class.base_class.name
      s.merge!(
        failed: true, 
        message: 'missmatched object types')
      return s
    end

    # All related non-annotation objects, by default
    self.class.transaction do
      merge_relations.each do |r|

        i = o.send(r.name)
        next if i.nil?

        # Discern b/w has_one and has_many
        if i.class.name.match('CollectionProxy')

          next unless i.any?

          s.merge!(
            r.name => {
              merged: 0,
              unmerged: 0 }
          )

          o.send(r.name).find_each do |j|
            j.update_attribute(r.options[:inverse_of], self)
            log_unify_result(j, r, s)
          end
          
        else
          s.merge!(
            r.name => {
              merged: 0,
              unmerged: 0 }
          )

          i.update_attribute(r.options[:inverse_of], self)
          log_unify_result(i, r, s)
        end
      end

      # TODO: explore further
      begin
        o.destroy!
      rescue ActiveRecord::InvalidForeignKey
        s.merge!(
          object: {
            errors: [
              { message: 'prevented by foreign_key' }
            ]
          }
        )
      end

      if preview
        raise ActiveRecord::Rollback 
      end 

    end
    s
  end

  def unify_relations_metadata
    s = {}
    merge_relations.each do |r|
      i = send(r.name)
      next if i.nil?
      if i.class.name.match('CollectionProxy')
        next unless i.count > 0
        s[r.name] = { total: i.count }
      else
        s[r.name] = { total: 1 }
      end
    end
    s
  end

  private

  # TODO: add error array
  def log_unify_result(object, relation, result)
    if object.errors.any?
      result[relation.name][:unmerged] += 1
      # TODO - delete/cleanup logic

    else
      
      result[relation.name][:merged] += 1
    end
  end

end
