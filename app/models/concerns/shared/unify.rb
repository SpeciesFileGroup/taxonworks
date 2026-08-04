# A module to unify two objects into 1, or to move data between objects.
#
# !! The module works on relations, not attributes, which are ignored and untouched (but see position, and is_original).
# !! For example if two objects have differing `name` fields this is ignored.
#
# When :only or :except are provided, then the remove_object IS NOT DESTROYED, only data are moved between objects.
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

    pre_validate(remove_object, s)
    return s if s[:result][:unified] == false
    pid = s[:result][:target_project_id]

    # Whether this call intends to fully destroy remove_object (as opposed
    # to only:/except: moving some data between the two objects).
    will_destroy = only.empty? && except.empty?
    destroy_key = { id: remove_object.id, type: remove_object.class.base_class.name }

    # Memoize reassign_foreign_keys outcomes _on a given related object_ of
    # remove_object: *all* FKs on the object are moved when the first FK is
    # encountered, but we still want to visit each FK separately (in the
    # uncommon case that there's more than one) in our FK loop below to accrue
    # counts correctly.
    resolved_unify_outcomes = {}

    relations = merge_relations(only:, except:)
    allowed_associations = relations.map { |r| r.options[:inverse_of] }.compact

    self.class.transaction do
      # before_unify # potential hooks, appear not to be required

      # Record remove_object as committed-to-destruction *before* any related
      # records are touched below, so those related records can see, for the
      # whole duration of this call (including any nested unify a dedup
      # triggers), that it's already slated for destruction.
      if will_destroy
        UnifyDestroyContext.objects_in_destroy ||= Set.new
        UnifyDestroyContext.objects_in_destroy << destroy_key
      end

      begin
        relations.each do |r|
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
              key = [j.class.base_class.name, j.id]
              outcome = resolved_unify_outcomes[key] ||= begin
                reassign_foreign_keys(
                  j, remove_object, r.options[:inverse_of], allowed_associations
                )
                resolve_unify_outcome(j)
              end
              apply_unify_outcome(outcome, n, s)
            end

            restore_list_order(list_state) if list_state

          when :has_one, :belongs_to
            i = remove_object.send(r.name)
            if !i.nil?
              stub_unify_result(s, n, 1)

              key = [i.class.base_class.name, i.id]
              outcome = resolved_unify_outcomes[key] ||= begin
                reassign_foreign_keys(
                  i, remove_object, r.options[:inverse_of], allowed_associations
                )
                resolve_unify_outcome(i)
              end
              apply_unify_outcome(outcome, n, s)
            end
          end
        end

        if cutoff_hit = s[:result][:total_related] > cutoff
          s[:result][:unified] = false
          s[:result][:message] = "Related cutoff threshold (> #{cutoff}) hit, unify is not yet allowed on these objects."
        elsif s[:result][:unified] != false

          begin
            remove_object.reload # reset all in-memory has_many caches that would prevent destroy

            remove_object.destroy! if will_destroy

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
      ensure
        UnifyDestroyContext.objects_in_destroy&.delete(destroy_key) if will_destroy
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
        s[:result].merge!(
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

  # Reassign every belongs_to FK on `record` that currently points at
  # `remove_object` to self, in a single update.
  #
  # (Needed for self-referential records - e.g. a TaxonNameRelationship
  # whose subject_taxon_name and object_taxon_name are both remove_object.
  # Moving such relations one at a time introduces meaningless intermediate
  # states we would nonetheless act on as if they were final state.)
  def reassign_foreign_keys(
    record, remove_object, primary_association, allowed_associations
  )
    associations = foreign_keys_pointing_at(record, remove_object).map(&:name)
    associations &= allowed_associations
    associations |= [primary_association]

    record.update(associations.index_with { self }) # errors stored on record
  end

  # @return Array of ActiveRecord::Reflection
  #   record's belongs_to associations - polymorphic or not - whose current
  #   FK value points at remove_object. Non-polymorphic associations are
  #   matched by id and STI base class; polymorphic ones additionally by
  #   the *_type column, compared against remove_object.class.polymorphic_name
  #   (the same value Rails itself would write there on assignment).
  def foreign_keys_pointing_at(record, remove_object)
    record.class.reflect_on_all_associations(:belongs_to).select do |a|
      next false unless record.read_attribute(a.foreign_key) == remove_object.id

      if a.polymorphic?
        record.read_attribute(a.foreign_type) == remove_object.class.polymorphic_name
      else
        a.klass.base_class == remove_object.class.base_class
      end
    end
  end

  # @param object [ActiveRecord::Base] see resolve_unify_outcome
  def deduplicate_update_target(object)
    i = object.identical

    if i.size == 1
      # There is exactly 1 match, merge is unambiguous.
      j = i.first
      # object's own FK is still dirty from the failed update attempt (it
      # points at self/KEEP, not its real enclosing remove_object); reload so
      # the nested unify below moves object's actual remaining relations, not
      # phantom ones based on that dirty state.
      j.unify(object.reload)
    else
      # Merge would be ambiguous, there are multiple matches.
      return false
    end
  end

  # Attempts the fixups and dedup fallback for a record whose FK(s) were
  # just (attempted to be) reassigned to self.
  #
  # @param object [ActiveRecord::Base] a record in another table that has a
  #   FK pointing to the remove_object (DESTROY) being unified away; the
  #   unify loop just attempted to flip that FK to self (KEEP) and the
  #   attempted update is reflected in object's in-memory state even if the
  #   save failed
  # @return [Hash] one of:
  #   { status: :merged }
  #   { status: :deduplicated }
  #   { status: :unmerged, id:, message: }
  def resolve_unify_outcome(object)
    # Handle an edge case, preserve Citations that would only be invalid due to
    # origin flag.
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
      # safe to attempt for *any* validation failure.
      dedup_result = deduplicate_update_target(object)
      if dedup_result && dedup_result[:result][:unified]
        { status: :deduplicated }
      else
        { status: :unmerged, id: object.id, message: object.errors.full_messages.join('; ') }
      end
    else
      { status: :merged }
    end
  end

  # Applies an outcome from resolve_unify_outcome to relation_name's tally
  # in result[:details]. See resolve_unify_outcome.
  def apply_unify_outcome(outcome, relation_name, result)
    case outcome[:status]
    when :merged
      result[:details][relation_name][:merged] += 1
    when :deduplicated
      result[:details][relation_name][:deduplicated] += 1
    when :unmerged
      result[:result][:unified] = false
      result[:details][relation_name][:unmerged] += 1
      result[:details][relation_name][:errors] ||= []
      result[:details][relation_name][:errors].push({id: outcome[:id], message: outcome[:message]})
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
