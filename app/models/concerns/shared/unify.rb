# A module to unify two objects into 1.
#  * Annotation classes can not be unified.
#  * Users and projects can not be unified, though technically the approach should be be a hard/but robust approach to the problem, with some key exceptions (e.g. two root TaxonNames)
#  * Base attributes of the object (.e.g. name) being destroyed are not copied nor persisted back into the remaining object
#  * Any related object that, once updated to point to its new object, that fails to save, _is destroyed_.  The assumption
#  is that there are duplicate values or other constraints that make the object redundant, as if it was being added a-new.
#  * `preview` rolls back all changes
#  * Run `rake tw:development:linting:inverse_of_preventing_unify` judiciously when modifying models or this code. It will catch missing `inverse_of` parameters required to unify objects.  Note that it will always report some missing relationships that do not matter.
#
# TODO:
#   - consider `strict` mode, where a preview is auto-run then inspected for any errors, if present the unify fails
#   - Attempt to move annotations from unsavable objects over, or consider hooks for this.
#     - Requires a generic duplicate method?!
#       -
#
module Shared::Unify
  extend ActiveSupport::Concern

  # Never auto-handle these, let the final destroy remove them.
  # Housekeeping relations are not hit here, we don't merge users at the moment.
  EXCLUDE_RELATIONS = [
    :versions,       # Not picked up, but adding in case
    :dwc_occurrence, # Will be destroyed on related objects destruction
    :pinboard_items, # Technically not needed here
    # !! TODO: check :taxon_name_hierarchies,
  ]

  # Per class, Iterating through all of these
  def only_relations
    []
  end

  # Per class, when merging skip these relations
  def except_relations
    []
  end

  # @return Array of ActiveRecord::Reflection
  # Perhaps used_inferred to hash
  def merge_relations(only: [], except: [])
    if (only_relations + [only&.map(&:to_sym)].flatten).uniq.any?
      o = (only_relations + [only&.map(&:to_sym)].flatten).uniq
      used_inferred_relations.select{|a| o.include?(a.name)}
    else
      e = (except_relations + [except&.map(&:to_sym)].flatten).uniq
      used_inferred_relations.select{|a| !e.include?(a.name)}
    end
  end

  # @return Array of ActiveRecord::Reflection
  #
  # Our target is a list of relations that we can
  # iterate through and, by inspection, update
  # related records to point to self.
  #  * We don't want to target convienience relations as they are in essence alias of base-class relations and redundant
  #  * We don't want anything that relates to a calculated cached value
  #  * We *do* want to catch relations that are edges in which the same class of object is on both sides, these require
  #   an alias.  We inspect for `related_<name>` as a pattern to select these.
  #
  #  TODO: Revist. depending on the`related_XXX naming pattern is brittle-ish.
  #     Is there some other reason those with class_name fail that we are missing?
  #
  def inferred_relations
    (ApplicationEnumeration.klass_reflections(self.class) +
     ApplicationEnumeration.klass_reflections(self.class, :has_one))
      .delete_if{|r| r.options[:foreign_key] =~ /cache/}
      .delete_if{|r| EXCLUDE_RELATIONS.include?(r.name.to_sym)}
      .delete_if{|r| !r.name.match(/related/) && ( r.options[:through].present? || r.options[:class_name].present? )}
  end

  # @return Array of ActiveRecord::Reflection
  # Keep separated from inferred_relations so we can better audit all models in rake linting
  def used_inferred_relations
    inferred_relations.select{|r| !r.options[:inverse_of].nil?}
  end

  # TODO: this should just be handled with after destroy ...
  #
  # Methods to be called per Class immediately before the transaction starts
  #  TODO: use with super, cleanup pinboard items inside of transaction
  def before_unify
  end

  # Methods to be called per Class after unify but before object is destroyed
  def after_unify
  end

  # re-visit this concept remove is_data?
  # @return Boolean
  #   true - there is no FK or polymorphic reference to this object
  #        - this object is not a blessed or special class record (e.g. a Root taxon name)
  def used?
  end

  # TODO: consider
  #   - a merge with preview = true wrapped in a transaction that you can roll back
  def mergeable?(remove_object)
    # !! Proxy
    # Otu.first.merge_relations.collect{|r| [r.options[:inverse_of], r.name]} -> can have no nil in first position
    #   - if nil then assume it's canonical form
    # TODO:
    #   - eliminate COMMUNITY data
    #   - maybe a class method Otu.new. ....
    #   - Both belong to the same project
    #
  end

  # Unify is not the same as move. For example we could move annotations
  # from one class of things to another, we can not do that here.

  # @return Hash
  #   a result
  #
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
            j.update(r.options[:inverse_of] => self)
            log_unify_result(j, r, s)
          end

        else
          s.merge!(
            r.name => {
              merged: 0,
              unmerged: 0 }
          )

          i.update(r.options[:inverse_of] => self)
          log_unify_result(i, r, s)
        end
      end

      # TODO: explore further, the preventing objects should all be moved or destroyed if properly iterated through
      begin
        o.reload # reset all in-memory has_many caches that would prevent destroy
        o.destroy!
      rescue ActiveRecord::InvalidForeignKey => e
        s.merge!(
          object: {
            errors: [
              { id: e.record.id, message: e.record.errors.full_messages.join('; ') } # e.message.to_s
            ]
          }
        )

        raise ActiveRecord::Rollback
      rescue ActiveRecord::RecordNotDestroyed => e
        s.merge!(
          object: {
            errors: [
              { id: e.record.id, message: e.record.errors.full_messages.join('; ') }
            ]
          }
        )

        raise ActiveRecord::Rollback
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

  def deduplicate_update_target(object)


    i = object.identical

    # There is exactly 1 match, merge is unambiguous
    if i.size == 1
      j = i.first
      j.unify(object)
    else
      # Merge would be ambiguous, there are multiple matches
      return false
    end
  end

  # @return Hash
  # TODO: add error array
  def log_unify_result(object, relation, result)
    if object.invalid?

      # Here we check to see that error related
      # to the object being unified, if not,
      # we don't know how to handle this with confidence.
      if object.errors.details.keys.include?(relation.options[:inverse_of])

        # object can't be updated, move it's annotations to self
        unless deduplicate_update_target(object)
          result[relation.name][:unmerged] += 1
          result[relation.name][:errors] ||= []
          result[relation.name][:errors].push {id: object.id, message: object.errors.full_messages.join('; ')} 
        
        else
          result[relation.name][:merged] += 1
        end
      end

      # TODO - delete/cleanup logic here?
    else
      result[relation.name][:merged] += 1
    end

    result
  end

end
