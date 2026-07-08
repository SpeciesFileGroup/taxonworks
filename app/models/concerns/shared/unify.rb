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
    :versions,             # Not picked up, but adding in case
    :dwc_occurrence,       # Will be destroyed on related objects destruction
    :pinboard_items,       # Technically not needed here
    :cached_map_register,  # Destroyed on merge of things like Georeferences and AssertedDistributions
    :cached_map_items,
    :cached_maps           # Destroy alternate,
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
    o = (only_relations + [only&.map(&:to_sym)].flatten).uniq
    if o.any?
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
  #   an alias. We inspect for `related_<name>` as a pattern to select these.
  #
  #  TODO: Revist. depending on the`related_XXX naming pattern is brittle-ish, perhaps
  #  converge on using `unife_relations` to force inclusion.
  #
  # Note: class_name based exclusions prevent a lot of duplicated efforts, as much of their use
  # is based on convienience relations on things like subclassed or scoped data.
  #
  def inferred_relations
    ( unify_relations +
     ::ApplicationEnumeration.klass_reflections(self.class, :has_many) +
     ::ApplicationEnumeration.klass_reflections(self.class, :has_one))
      .delete_if{|r| r.options[:foreign_key] =~ /cache/}
      .delete_if{|r| EXCLUDE_RELATIONS.include?(r.name.to_sym)}
      .delete_if{|r| !r.name.match(/related/) && ( r.options[:through].present? || r.options[:class_name].present? )}
  end

  # @return Array of ActiveRecord::Reflection
  # Keep separated from inferred_relations so we can better audit all models in rake linting
  def used_inferred_relations
    (inferred_relations.select{|r| !r.options[:inverse_of].nil?} + unify_relations).uniq
  end

  # Override in instances methods, see Serial for eg
  def unify_relations
    []
  end

  # Override to prepare an object for its own destruction by unify, e.g. to
  # flag a validation on a still-alive parent that would otherwise block the
  # destroy (see Citation, whose citation_object may require at least one
  # citation - moot once citation_object is itself confirmed to be the
  # record actually being destroyed).
  #
  # @param on_behalf_of [ActiveRecord::Base, nil]
  #   Normally nil (a plain, top-level #unify call destroys remove_object for
  #   its own sake). Set only when this destroy is happening because
  #   deduplicate_update_target found a duplicate and is merging it away --
  #   in that case it's the parent (remove_object) of the #unify call that
  #   triggered the merge. Hooks use it to recognize "the thing I'd
  #   otherwise need to protect is about to be destroyed anyway, for an
  #   unrelated reason" -- see Citation, which skips its at-least-one-
  #   citation guard when its own citation_object is on_behalf_of.
  def prepare_for_unify_destroy(on_behalf_of)
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
  # @param on_behalf_of [ActiveRecord::Base, nil]
  #   see Shared::Unify#prepare_for_unify_destroy; set internally by
  #   deduplicate_update_target, not intended to be passed by other callers
  #
  def unify(remove_object, only: [], except: [], preview: false, cutoff: 250, target_project_id: nil, on_behalf_of: nil)
    s = {
      result: { unified: nil, total_related: 0, target_project_id:},
      details: {},
    }

    pre_validate(remove_object, s)
    return s if s[:result][:unified] == false
    pid = s[:result][:target_project_id]

    self.class.transaction do
      # before_unify # potential hooks, appear not to be required

      merge_relations(only:, except:).each do |r|
        n = relation_label(r)

        case ::ApplicationEnumeration.relationship_type(r)

        when :has_many
          i = remove_object.send(r.name)

          unless ::ApplicationEnumeration.relation_targets_community?(r)
            i = i.where(project_id: pid)
          end

          next unless i.any?

          t = i.size
          stub_unify_result(s, n, t)

          s[:result][:total_related] += t
          next if s[:result][:total_related] > cutoff

          list_state = snapshot_list_order(r, i)

          i.find_each do |j|
            j.update(r.options[:inverse_of] => self)
            log_unify_result(j, r, s, remove_object)
          end

          restore_list_order(list_state) if list_state

        when :has_one, :belongs_to
          i = remove_object.send(r.name)
          if !i.nil?
            stub_unify_result(s, n, 1)

            i.update(r.options[:inverse_of] => self)
            log_unify_result(i, r, s, remove_object)
          end
        end
      end

      if cutoff_hit = s[:result][:total_related] > cutoff
        s[:result][:unified] = false
        s[:result][:message] = "Related cutoff threshold (> #{cutoff}) hit, unify is not yet allowed on these objects."
      elsif s[:result][:unified] != false

        begin
          remove_object.reload # reset all in-memory has_many caches that would prevent destroy

          unless only.any? || except.any?
            remove_object.prepare_for_unify_destroy(on_behalf_of)
            remove_object.destroy!
          end

        rescue ActiveRecord::InvalidForeignKey => e
          # InvalidForeignKey comes from the DB adapter, so e has no `.record`.
          s[:result][:unified] = false
          s[:details].merge!(
            Object: {
              errors: [
                {
                  id: remove_object.id,
                  exception: e.class.name,
                  message: e.message
                }
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

      # after_unify # potential hooks, appear not to be required

      if preview || cutoff_hit || s[:result][:unified] == false
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
      name = relation_label(r)

      case ::ApplicationEnumeration.relationship_type(r)
      when :has_many
        if ::ApplicationEnumeration.relation_targets_community?(r)
          i = send(r.name)
        else
          i = send(r.name).where(project_id: target_project_id)
        end

        next unless i.count > 0
        s[r.name] = { total: i.count, name: }
      when :has_one
        if send(r.name).present?
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

  # @param object [ActiveRecord::Base] see log_unify_result
  # @param enclosing_remove_object [ActiveRecord::Base] see log_unify_result - object's real parent
  def deduplicate_update_target(object, enclosing_remove_object)
    i = object.identical

    # There is exactly 1 match, merge is unambiguous
    if i.size == 1
      j = i.first
      # object's own FK is still dirty from the failed update attempt (it
      # points at self/KEEP, not enclosing_remove_object); reload so the
      # nested unify below moves object's actual remaining relations, not
      # phantom ones based on that dirty state.
      j.unify(object.reload, on_behalf_of: enclosing_remove_object)
    else
      # Merge would be ambiguous, there are multiple matches
      return false
    end
  end

  # During logging attempt to resolve duplicate
  # objects issues by moving annotations from the
  # would-be duplicate to an identical existing record.
  #
  # @param object [ActiveRecord::Base] a record in another table that has a FK
  #   pointing to the remove_object (DESTROY) being unified away; the unify loop
  #   just attempted to flip that FK to self (KEEP) and the attempted update is
  #   reflected in object's in-memory state even if the save failed
  # @param relation [ActiveRecord::Reflection] the has_many/has_one reflection
  #   on self (KEEP) for the association being processed;
  #   relation.options[:inverse_of] is the belongs_to on object's class whose FK
  #   we tried to flip
  # @param result [Hash] the running unify result accumulator
  # @param enclosing_remove_object [ActiveRecord::Base] the remove_object of
  #   the enclosing #unify call - object's real parent
  def log_unify_result(object, relation, result, enclosing_remove_object)
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

    if object.errors.any?
      # If the attempted move failed, it may be because an identical record
      # already exists on self (a duplicate) - try to find and merge into it.
      # #identical won't match unless there's a genuine duplicate, so this is
      # safe to attempt for *any* validation failure, not just the ones that
      # look like a uniqueness conflict.
      dedup_result = deduplicate_update_target(object, enclosing_remove_object)
      # object was never reloaded here unless deduplicate_update_target found
      # a single identical match (in which case success/failure is decided by
      # the nested unify's own result, not object's own validity) -- so in
      # the "no match" case object is still exactly as invalid as it was when
      # `object.errors.any?` was checked above. There's no state in between
      # where it could have become valid, so there's nothing to re-check.
      if dedup_result && dedup_result[:result][:unified]
        result[:details][n][:deduplicated] += 1
      else
        result[:result][:unified] = false
        result[:details][n][:unmerged] += 1
        result[:details][n][:errors] ||= []
        result[:details][n][:errors].push( {id: object.id, message: object.errors.full_messages.join('; ')} )
      end
    else
      # The update succeeded outright. Do not reload: reload clears the
      # in-memory dirty-tracking (`saved_changes`/`_previously_changed?`)
      # that object's own deferred `after_commit` callbacks may depend on
      # to decide whether to recompute cached values (e.g. TaxonNameRelationship).
      result[:details][n][:merged] += 1
    end

    result
  end

  def stub_unify_result(result, relation_name, attempted)
    result[:details].merge!(
      relation_name => {
        attempted:,
        merged: 0,
        unmerged: 0,
        deduplicated: 0
      }
    )
  end

  # Snapshot the current position order on both sides of a has_many before
  # records are re-parented, so the restore below is independent of how
  # acts_as_list repositions records during update.
  # Returns nil when the association does not use acts_as_list.
  def snapshot_list_order(relation, incoming)
    related_class = incoming.klass
    return nil unless related_class.respond_to?(:acts_as_list_options)
    {
      klass: related_class,
      existing_ids: send(relation.name).order(:position).pluck(:id),
      incoming_ids: incoming.order(:position).pluck(:id)
    }
  end

  # Re-apply the pre-merge position order captured by snapshot_list_order,
  # appending incoming records after the surviving object's existing records.
  def restore_list_order(state)
    (state[:existing_ids] + state[:incoming_ids]).each_with_index do |id, idx|
      state[:klass].where(id:).update_all(position: idx + 1)
    end
  end

end
