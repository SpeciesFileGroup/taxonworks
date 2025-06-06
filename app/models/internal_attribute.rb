# The DataAttribute that has a Predicate that is internally defined in TaxonwWorks.
#
# Internal attributes have stronger semantics that ImportAttributes in that the user has had to first
# create a Predicate (which is a controlled vocabulary subclass), which in turn requires a definition.

# @!attribute controlled_vocabulary_term_id
#   @return [id]
#   The the id of the ControlledVocabularyTerm::Predicate.  Term is referenced as #predicate.
#
class InternalAttribute < DataAttribute
  include Shared::DwcOccurrenceHooks

  validates :predicate, presence: true
  validates :value, uniqueness: { scope: [:attribute_subject_id, :attribute_subject_type, :type, :controlled_vocabulary_term_id, :project_id] }

  def dwc_occurrences
    if DWC_ATTRIBUTE_URIS.values.flatten.include?(predicate&.uri)
      # TODO: probably use some generic interface here
      case attribute_subject_type
      when 'CollectingEvent'
        # TODO - validate empty is not happening here.
        ::Queries::DwcOccurrence::Filter.new(
          collecting_event_query: {
            collecting_event_id: attribute_subject_id }
        ).all
      when 'CollectionObject'
        ::DwcOccurrence.where(
          dwc_occurrence_object_id: attribute_subject_id,
          dwc_occurrence_object_type: 'CollectionObject')
      else
        ::DwcOccurrence.none
      end
    else
      ::DwcOccurrence.none
    end
  end

  # @params subject_scope a Query::X::Filter instance
  #   that is NOT Query::DataAttribute::Filter
  def self.update_value(subject_scope, predicate_id, value_from, value_to)
    total = identifiers_on_subjects_count(subject_scope, predicate_id)
    b = ::InternalAttribute
      .with(attr_subject_ids: subject_scope.select(:id))
      .where('attribute_subject_id IN (SELECT id FROM attr_subject_ids)')
      .where(value: value_from)

    updated = b.count # count before you change values read by the query!
    # update_all doesn't work with .with() (at least here)
    ::InternalAttribute.where(id: b).update_all(value: value_to)

    [total, updated]
  end

  # Add attributes to the objects in the filter that do not have them
  def self.add_value(subject_scope, predicate_id, value_to)
    # with (not these)
    a = subject_scope.joins(:internal_attributes).where(
      data_attributes: {
        value: value_to,
        controlled_vocabulary_term_id: predicate_id
      })
    # If the join is empty, we need to add to all
    if a.size == 0
      b = subject_scope
    else
      klass = subject_scope.name.underscore.pluralize
      t = subject_scope.klass
        .with(klass_ids: a.select(:id))
        .joins("LEFT JOIN klass_ids ON klass_ids.id = #{klass}.id")
        .where('klass_ids.id IS null')
      b = subject_scope.from("(#{t.to_sql}) AS #{klass}")
    end

    added = b.count
    ::InternalAttribute.transaction do
      b.each do |o|
        begin
          ::InternalAttribute.create!(
            controlled_vocabulary_term_id: predicate_id,
            value: value_to,
            attribute_subject: o,
          )
        rescue ActiveRecord::RecordInvalid => e
          # TODO: check necessity of this
          # This should not be necessary, but proceed
        end
      end
    end

    [subject_scope.count, added]
  end

  # @return [Number] total processed, total removed
  def self.remove_value(subject_scope, predicate_id, value)
    total = identifiers_on_subjects_count(subject_scope, predicate_id)

    # delete_all doesn't support .with()
    s = "WITH attr_subject_ids AS ( #{ subject_scope.select(:id).to_sql } ) "
    s << ::InternalAttribute
      .where(
        'attribute_subject_id IN (SELECT id FROM attr_subject_ids)'
      )
      .where(
        attribute_subject_type: subject_scope.name,
        controlled_vocabulary_term_id: predicate_id,
        value:,
      ).to_sql

    q = ::InternalAttribute.from( "(#{s}) AS data_attributes")

    removed = q.count
    # Beware q.delete_all here!
    ::InternalAttribute.where(id: q).delete_all

    [total, removed]
  end

  def self.process_batch_by_filter_scope(batch_response: nil, query: nil,
    hash_query: nil, mode: nil, params: nil, async: nil,
    project_id: nil, user_id: nil,
    called_from_async: false
  )
    # Don't call async from async (the point is we do the same processing in
    # async and not in async, and this function handles both that processing and
    # making the async call, so it's this much janky).
    async = false if called_from_async == true
    r = batch_response

    case mode.to_sym
    when :replace
      if params[:predicate_id].nil?
        r.errors['no predicate id provided'] = nil
        return r
      elsif params[:value_from].nil?
        r.errors["no 'from' value provided"] = nil
        return r
      elsif params[:value_to].nil?
        r.errors["no 'to' value provided"] = nil
        return r
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query:,
          mode:,
          params:,
          project_id:,
          user_id:
        )
        return r
      end

      attempted, updated = update_value(
        query, params[:predicate_id], params[:value_from], params[:value_to]
      )

      r.total_attempted = Array.new(attempted)
      r.updated = Array.new(updated)
      r.not_updated = Array.new(attempted - updated)

    when :remove
      if params[:predicate_id].nil?
        r.errors['no predicate id provided'] = nil
        return r
      elsif params[:value].nil?
        r.errors['no predicate value provided'] = nil
        return r
      end

      # No async here, just bulk delete.
      attempted, removed =
        remove_value(query, params[:predicate_id], params[:value])

      r.total_attempted = Array.new(attempted)
      r.updated = Array.new(removed)
      r.not_updated = Array.new(attempted - removed)

    when :add
      if params[:predicate_id].nil?
        r.errors['no predicate id provided'] = nil
        return r
      elsif params[:value].nil?
        r.errors['no predicate value provided'] = nil
        return r
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query:,
          mode:,
          params:,
          project_id:,
          user_id:,
        )
        return r
      end

      attempted, added =
        add_value(query, params[:predicate_id], params[:value])

      r.total_attempted = Array.new(attempted)
      r.updated = Array.new(added)
      r.not_updated = Array.new(attempted - added)
    end

    r
  end

  def self.identifiers_on_subjects_count(subjects_query, predicate_id)
    # How many data attributes total are on our subjects?
    ::InternalAttribute
      .with(attr_subject_ids: subjects_query.select(:id))
      .where('attribute_subject_id IN (SELECT id FROM attr_subject_ids)')
      .count
  end
end
