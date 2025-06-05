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

  # @params attribute_scope a Query::X::Filter instance
  #   that is NOT Query::DataAttribute::Filter
  # @return [Number or False] number of records updated
  def self.update_value(attribute_scope, controlled_vocabulary_term_id, value_from, value_to)
    return false if controlled_vocabulary_term_id.nil? || value_from.nil? || value_to.nil?

    b = ::DataAttribute
      .with(attr_subject_ids: attribute_scope.select(:id))
      .where('attribute_subject_id IN (SELECT id FROM attr_subject_ids)')
      .where(value: value_from, type: 'InternalAttribute')

    count = b.count # count before you change values read by the query!
    # update_all doesn't work with .with() (at least here)
    ::DataAttribute.where(id: b).update_all(value: value_to)

    count
  end

  # Add attributes to the objects in the filter that do not have them
  #
  # @return [Array or False] array of internal attribute ids created
  def self.add_value(attribute_scope, controlled_vocabulary_term_id, value_to)
    return false if controlled_vocabulary_term_id.nil? || value_to.nil?
    rv = []

    # with (not these)
    a = attribute_scope.joins(:internal_attributes).where(
      data_attributes: {
        value: value_to,
        controlled_vocabulary_term_id:
      })
    # If the join is empty, we need to add to all
    if a.size == 0
      b = attribute_scope
    else
      klass = attribute_scope.name.underscore.pluralize
      t = attribute_scope.klass
        .with(klass_ids: a.select(:id))
        .joins("LEFT JOIN klass_ids ON klass_ids.id = #{klass}.id")
        .where('klass_ids.id IS null')
      b = attribute_scope.from("(#{t.to_sql}) AS sounds")
    end

    InternalAttribute.transaction do
      b.each do |o|
        begin
          ia = ::InternalAttribute.create!(
            controlled_vocabulary_term_id:,
            value: value_to,
            attribute_subject: o,
          )

          rv.push(ia.id)
        rescue ActiveRecord::RecordInvalid => e
          # TODO: check necessity of this
          # This should not be necessary, but proceed
        end
      end
    end

    rv
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
      else
        num_updated = update_value(
          query, params[:predicate_id], params[:value_from], params[:value_to]
        )

        r.updated = Array.new(num_updated)
      end

    when :remove
      # Just delete, async or not
      if params[:predicate_id].nil?
        r.errors['no predicate id provided'] = nil
        return r
      elsif params[:value].nil?
        r.errors['no predicate value provided'] = nil
        return r
      end

      # delete_all doesn't support .with()
      s = "WITH attr_subject_ids AS ( #{ query.select(:id).to_sql } ) "
      s << ::DataAttribute
        .where(
          'attribute_subject_id IN (SELECT id FROM attr_subject_ids)'
        )
        .where(
          attribute_subject_type: query.name,
          controlled_vocabulary_term_id: params[:predicate_id],
          value: params[:value],
          # query is on DataAttribute, so we need to do this
          type: 'InternalAttribute'
        ).to_sql

      q = ::DataAttribute.from( "(#{s}) AS data_attributes")

      r.updated = Array.new(q.count)
      # Beware q.delete_all!
      ::DataAttribute.where(id: q).delete_all

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
      else
        ia_ids = add_value(query, params[:predicate_id], params[:value])
        r.updated = ia_ids
      end

    end

    return r
  end
end
