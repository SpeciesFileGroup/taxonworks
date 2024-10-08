# A module to unify two objects into 1, or to move data between objects.
#
# !! The module works on relations, not attributes, which are ignored and untouched (but see position, and is_original).
# !! For example if two objects have differing `name` fields this is ignored.
#
# When :only or :except are provided, then the remove_object IS NOT DESTROYED, only data are moved between objects.555h
#
# If they are not provided, we attempt to destroy the `remove_object`
#  * If a related object is now a duplicate then its annotations are moved to the deduplicate object
#  * If `preview` = true then rolls back all changes.
#
# * Annotation classes (e.g. Notes) can not be unified except through their relation to unified objects.
# * Users and projects can not be unified, though technically the approach should be be a hard/but robust approach to the problem, with some key exceptions (e.g. two root TaxonNames)
#
# * Classes that are exposed in the UI are defined at app/javascript/vue/tasks/unify/objects/constants/types.js.
# * Run `rake tw:development:linting:inverse_of_preventing_unify` judiciously when modifying models or this code. It will catch missing `inverse_of` parameters required to unify objects.  Note that it will always report some missing relationships that do not matter.
#
module Shared::Unify
  extend ActiveSupport::Concern

  # Never auto-handle these, let the final destroy remove them.
  # Housekeeping relations are not hit here, we don't merge users at the moment.
  EXCLUDE_RELATIONS = [
    :versions,       # Not picked up, but adding in case
    :dwc_occurrence, # Will be destroyed on related objects destruction
    :pinboard_items, # Technically not needed here
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
  #  TODO: Is there some other reason those with class_name fail that we are missing?
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

  # TODO: Not yet used, likely not needed.
  # Methods to be called per Class immediately before the transaction starts
  def before_unify
    # use with super perhaps
    # consider things like pinboard_items
  end

  # TODO: Not yet used, likely not needed.
  # Methods to be called per Class after unify but before object is destroyed
  def after_unify
  end

  # re-visit this concept remove is_data?
  # @return Boolean
  #   true - there is no FK or polymorphic reference to this object
  #        - this object is not a blessed or special class record (e.g. a Root taxon name)
  def used?
  end

  # See header.
  #
  # @return Hash
  #   a result
  #
  # @param remove_object
  #    this object will be destroyed if possible
  #
  # @param only [Array of Symbols]
  #    only operate on these relations, useful for partial merges/moving objects
  #
  # @param except [Array of Symbols]
  #    don't operate on these relations
  #
  # @param preview Boolean
  #    if true then roll back all operations
  #
  # @param cutoff Integer
  #    if more than cutoff relations are observed then always rollback
  #    TODO: add delayed job handling
  #
  # @param target_project_id [Integer]
  #   required when self is_community?, scopes operations to target project only
  #
  def unify(remove_object, only: [], except: [], preview: false, cutoff: 250, target_project_id: nil)
    s = {
      result: { unified: nil, total_related: 0, target_project_id:},
      details: {},
    }

    o = remove_object
    pre_validate(o, s)
    return s if s[:result][:unified] == false
    pid = s[:result][:target_project_id]

    self.class.transaction do
      before_unify # does nothing yet maybe outside here

      merge_relations(only:, except:).each do |r|
        i = o.send(r.name)
        next if i.nil? # has_one case

        n = relation_label(r)

        i = i.where(project_id: pid)

        # Discern b/w has_one and has_many
        if r.class.name.match('HasMany')
          next unless i.any?

          s[:details].merge!(
            n => {
              merged: 0,
              unmerged: 0 }
          )

          q = o.send(r.name).where(project_id: pid)

          s[:result][:total_related] += q.count
          next if s[:result][:total_related] > cutoff

          q.find_each do |j|
            j.update(r.options[:inverse_of] => self)
            log_unify_result(j, r, s)
          end

        else
          s[:details].merge!(
            n => {
              merged: 0,
              unmerged: 0 }
          )

          i.update(r.options[:inverse_of] => self)
          log_unify_result(i, r, s)
        end
      end

      if cutoff_hit = s[:result][:total_related] > cutoff
        s[:result][:message] = "Related cutoff threshold (> #{cutoff}) hit, unify is not yet allowed on these objects."
      else
        begin
          o.reload # reset all in-memory has_many caches that would prevent destroy

          unless only.any? || except.any?
            o.destroy!
          end

        rescue ActiveRecord::InvalidForeignKey => e
          s[:result][:unified] = false
          s[:details].merge!(
            Object: {
              errors: [
                { id: e.record.id, message: e.record.errors.full_messages.join('; ') }
              ]
            }
          )

          raise ActiveRecord::Rollback
        rescue ActiveRecord::RecordNotDestroyed => e
          s[:result][:unified] = false
          s[:details].merge!(
            Object: {
              errors: [
                { id: e.record.id, message: e.record.errors.full_messages.join('; ') }
              ]
            }
          )

          raise ActiveRecord::Rollback
        end
      end

      after_unify

      if preview || cutoff_hit
        raise ActiveRecord::Rollback
      end
    end

    s[:result][:unified] = true unless s[:result][:unified] == false
    s
  end

  def relation_label(relation)
    relation.name.to_s.humanize
  end

  def unify_relations_metadata(target_project_id: nil)
    s = {}

    merge_relations.each do |r|
      i = self.send(r.name).where(project_id: target_project_id)
      next if i.nil?

      name = relation_label(r)

      if r.class.name.match('HasMany')
        next unless i.count > 0
        s[r.name] = { total: i.count, name: }
      else # TODO: HasOne check?!
        if i.send(r).present?
          s[r.name] = { total: 1, name: }
        end
      end
    end
    s.sort.to_h
  end

  private

  def pre_validate(remove_object, result)
    s = result

    if s[:result][:target_project_id].nil?
      if is_community?
        s[:result].merge!(
          unified: false,
          message: 'Can not merge community objects without project context.'
        )
      else
        s[:result][:target_project_id] = project_id
      end
    end

    if remove_object == self
      s[:result].merge!(
        unified: false,
        message: 'Can not unify the same objects.'
      )
    end

    if !is_community?
      if project_id != remove_object.project_id
        s.merge!(
          unified: false,
          message: 'Danger, objects come from different projects.')
      end
    end

    if remove_object.class.name != self.class.name
      s[:result].merge!(
        unified: false,
        message: "Can not unify objects of different types (#{remove_object.class.name} and #{self.class.name}).")
    end
    s
  end

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

  # During logging attempt to resolve duplicate
  # objects issues by moving annotations from the
  # would-be duplicate to an identical existing record.
  #
  # @return result Hash
  def log_unify_result(object, relation, result)
    n = relation.name.to_s.humanize

    # Handle an edge case, preserve Citations that
    # would only be invalid due to origin flag
    if object.class.name == 'Citation' && object.errors.key?(:is_original) && object.is_original
      object.is_original = false
      object.save
    end

    if object.errors.key?(:position)
      object.position = nil
      object.save
    end

    if object.invalid?

      # Here we check to see that the error is related
      # to the object being unified, if not,
      # we don't know how to handle this with confidence.
      if object.errors.details.keys.include?(relation.options[:inverse_of])

        # object can't be updated, move its annotations to self
        unless deduplicate_update_target(object)
          result[:result][:unified] = false
          result[:details][n][:unmerged] += 1
          result[:details][n][:errors] ||= []
          result[:details][n][:errors].push( {id: object.id, message: object.errors.full_messages.join('; ')} )
        else
          result[:details][n][:merged] += 1
        end
      end
    else
      result[:details][n][:merged] += 1
    end

    result
  end

end
