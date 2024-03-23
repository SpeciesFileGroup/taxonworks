# The DataAttribute that has a Predicate that is internally defined in TaxonwWorks.
#
# Internal attributes have stronger semantics that ImportAttributes in that the user has had to first
# create a Predicate (which is a controlled vocabulary subclass), which in turn requires a definition.

# @!attribute controlled_vocabulary_term_id
#   @return [id]
#   The the id of the ControlledVocabularyTerm::Predicate.  Term is referenced as #predicate.
#
class InternalAttribute < DataAttribute
  validates_presence_of :predicate
  validates_uniqueness_of :value, scope: [:attribute_subject_id, :attribute_subject_type, :type, :controlled_vocabulary_term_id, :project_id]

  after_save :update_dwc_occurrences

  # TODO: wrap in generic (reindex_dwc_occurrences method for use in InternalAttribute and elsewhere)
  # TODO: perhaps a Job
  def update_dwc_occurrences
    if DWC_ATTRIBUTE_URIS.values.flatten.include?(predicate.uri)

      if attribute_subject.respond_to?(:set_dwc_occurrence)
        attribute_subject.set_dwc_occurrence
      end

      if attribute_subject.respond_to?(:update_dwc_occurrences)
        attribute_subject.update_dwc_occurrences
      end
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

    s = 'WITH query_with_ia AS (' + a.to_sql + ') ' +
      attribute_scope.referenced_klass
      .joins("LEFT JOIN query_with_ia as query_with_ia1 ON query_with_ia1.id = #{attribute_scope.table.name}.id")
      .where("query_with_ia1.id is null")
      .to_sql

    b = attribute_scope.referenced_klass.from('(' + s + ") as #{attribute_scope.table.name}").distinct


    InternalAttribute.transaction do
      b.each do |o|
        ::InternalAttribute.create!(
          controlled_vocabulary_term_id:,
          value: value_to,
          attribute_subject: o)
      end
    end

  end

  # <some_object>_query={}&value_from=123&value_to=456&predicate_id=890

  def self.batch_update_or_create(params)
    a = Queries::Query::Filter.base_filter(params)

    b = a.new(params)

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
