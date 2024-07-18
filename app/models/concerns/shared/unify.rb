# Merge concepts
#
#   When b merges to a the operation is:
#     `complete` if b is left with no related data
#     `blocked` when merging is prevented by data validations
#
#  what about difference in values of the objects
#
#
# TODO:
#   -  mode strict => rollback if  *any* conflicting values?!
#   - Annotation classes can not be merged
#   - write spec that ensures :inverse_of is seat for all necessary classes
#       Otu.first.merge_relations.collect{|r| [r.options[:inverse_of], r.name]}
#
#   - Pinboard items should be destroyed, and not cause failure
#   - Mode that destroys invalid objects (e.g. global identifiers that can't be merged)
#
module Shared::Unify
  extend ActiveSupport::Concern

  # Never auto-handle these, let the final destroy remoe them.
  EXCLUDE_RELATIONS = [
    # TODO: all the housekeeping and project relations?
    :versions,      # Not picked up, but adding in case, these should be destoyed as well?
    :dwc_occurrence # Will be destroyed on CollectinoObject destroy
  ]

  # Per class, Iterating thorugh all of these
  def only_relations
    []
  end

  # Per class, when merging skip these relations
  def except_relations
    []
  end

  def merge_relations(only: [], except: [])
    if (only_relations + [only].flatten).uniq.any?
      (only_relations + [only].flatten).uniq
    else
      used_inferred_relations - (except_relations + [except].flatten).uniq
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
      .delete_if{|r| EXCLUDE_RELATIONS.include?(r.name.to_sym)}

    # TODO: eliminate relations with * where clauses * ?
  end

  # Remove nil.
  # Keep seperated from inferred_relations so we can better audi all models in specs
  def used_inferred_relations
    inferred_relations.select{|r| !r.options[:inverse_of].nil?}
  end

  # Methods to be called per Class immediately before the transaction starts
  #  TODO: use with super, cleanup pinboard items inside of transactionj<t_�X>
  def before_unify
    if respond_to?(:pinboard_items) 
      pinboard_items.destroy_all
    end

    if respond_to?(:versions)
      versions.destroy_all
    end
  end

  # Methods to be called per Class after unify but before object is destroyed
  def after_unify
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

      before_unify

      merge_relations(only:, except:).each do |r|

        i = o.send(r.name)
        next if i.nil? # has_one case

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

      # TODO: explore further, the preventing objects should all be moved or destroyed if properly iterated through
      begin
        o.destroy!
      rescue ActiveRecord::InvalidForeignKey => e
        s.merge!(
          object: {
            errors: [
              { message: e.message.to_s }
            ]
          }
        )

        raise ActiveRecord::Rollback
      rescue ActiveRecord::RecordNotDestroyed => e
        s.merge!(
          object: {
            errors: [
              { message: "record not destroyed {#{e.message.to_s}" }
            ]
          }
        )

        raise ActiveRecord::Rollback
        # rescue
        # raise ActiveRecord::Rollback
      end

      after_unify

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

      name = r.name.to_s.humanize

      if i.class.name.match('CollectionProxy')
        next unless i.count > 0
        s[r.name] = { total: i.count, name: }
      else
        s[r.name] = { total: 1, name: }
      end
    end
    s.sort.to_h
  end

  private

  # TODO: add error array
  def log_unify_result(object, relation, result)
    if object.errors.any?
      result[relation.name][:unmerged] += 1

      result[relation.name][:errors] ||= []
      result[relation.name][:errors].push(object.id)

      # TODO - delete/cleanup logic here?

    else
      result[relation.name][:merged] += 1
    end
  end

end
