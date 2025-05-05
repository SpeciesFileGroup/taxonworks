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

  validates_presence_of :predicate
  validates_uniqueness_of :value, scope: [:attribute_subject_id, :attribute_subject_type, :type, :controlled_vocabulary_term_id, :project_id]

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
  def self.update_value(attribute_scope, controlled_vocabulary_term_id, value_from, value_to)
    return false if controlled_vocabulary_term_id.nil? || value_from.nil? || value_to.nil?
    b = ::Queries::DataAttribute::Filter.new(
      attribute_scope.query_name.to_sym => attribute_scope.params,
      controlled_vocabulary_term_id:,
      value: value_from,
    )

    b.all.update_all(value: value_to)
  end

  # Add attributes to the objects in the filter that do not have them
  #
  # @return attribute_scope a Filter instance
  def self.add_value(attribute_scope, controlled_vocabulary_term_id, value_to)
    return false if controlled_vocabulary_term_id.nil? || value_to.nil?

    # with (not these)
    a = attribute_scope.all.joins(:internal_attributes).where(
      data_attributes: {
        value: value_to,
        controlled_vocabulary_term_id:
      })

    # If the join is empty, we need to add to all
    if a.size == 0
      b = attribute_scope.all
    else
      s = 'WITH query_with_ia AS (' + a.to_sql + ') ' +
        attribute_scope.referenced_klass
        .joins("LEFT JOIN query_with_ia as query_with_ia1 ON query_with_ia1.id = #{attribute_scope.table.name}.id")
        .where("query_with_ia1.id is null")
        .to_sql

      b = attribute_scope.referenced_klass.from('(' + s + ") as #{attribute_scope.table.name}").distinct
    end

    # stop-gap, we shouldn't hit this
    return false if b.size > 1000

    InternalAttribute.transaction do
      b.each do |o|
        begin
          ::InternalAttribute.create!(
            controlled_vocabulary_term_id:,
            value: value_to,
            attribute_subject: o)
        rescue ActiveRecord::RecordInvalid => e
          # TODO: check necessity of this
          # This should not be necessary, but proceed
        end
      end
    end
  end

  # <some_object>_query={}&value_from=123&value_to=456&predicate_id=890
  def self.batch_update_or_create(params)
    a = Queries::Query::Filter.base_filter(params)

    q = params.keys.select{|z| z =~ /_query/}.first

    return false if q.nil?

    b = a.new(params[q])

    s = b.all.count

    return false if b.params.empty? || s > 1000 || s == 0

    transaction do
      update_value(b, params[:predicate_id], params[:value_from], params[:value_to])
      add_value(b, params[:predicate_id], params[:value_to])
    end

    true
  end

  def self.batch_create(params)
    ids = params[:attribute_subject_id]
    params.delete(:attribute_subject_id)

    internal_attributes = []
    InternalAttribute.transaction do
      begin
        ids.each do |id|
          internal_attributes.push InternalAttribute.create!(
            params.merge(
              attribute_subject_id: id
            )
          )
        end
      rescue ActiveRecord::RecordInvalid
        return false
      end
    end
    internal_attributes
  end
end
