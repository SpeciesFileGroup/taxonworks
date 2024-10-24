# A Confidence is an annotation that links a user-defined confidence level to a
# data object. It is an assertion as to the quality of that data.
#
# @!attribute confidence_level_id
#   @return [Integer]
#     the controlled vocabulary term used in the confidence
#
# @!attribute confidence_object_id
#   @return [Integer]
#      Rails polymorphic. The id of of the object being annotated.
#
# @!attribute confidence_object_type
#   @return [String]
#      Rails polymorphic.  The type of the object being annotated.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute position
#   @return [Integer]
#     a user definable sort code on the tags on an object, handled by acts_as_list
#
class Confidence < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:confidence_object)

  acts_as_list scope: [:confidence_object_id, :confidence_object_type, :project_id]

  belongs_to :confidence_level, inverse_of: :confidences, validate: true
  belongs_to :controlled_vocabulary_term, foreign_key: :confidence_level_id, inverse_of: :confidences

  validates :confidence_level, presence: true
  validates_uniqueness_of :confidence_level_id, scope: [:confidence_object_id, :confidence_object_type]

  accepts_nested_attributes_for :confidence_level, allow_destroy: true

  def self.exists?(global_id, confidence_level_id, project_id)
    o = GlobalID::Locator.locate(global_id)
    return false unless o
    Confidence.where(project_id: project_id, confidence_object: o, confidence_level_id: confidence_level_id).first
  end

  def self.batch_by_filter_scope(filter_query: nil, confidence_level_id: nil, replace_confidence_level_id: nil, mode: :add, async_cutoff: 100)
    b = ::Queries::Query::Filter.instatiated_base_filter(filter_query)
    q = b.all(true)

    c = q.count

    async = c > async_cutoff ? true : false

    # Batch result
    r = ::BatchResponse.new(
      total_attempted: q.count,
      async:,
      preview: false,
      method: 'Confidence batch_by_filter_scope',
      klass: b.referenced_klass.name
    )

    case mode.to_sym
    when :replace
      # TODO: Return response
      if replace_confidence_level_id.nil?
        r.errors['no replacement confidence level provided'] = 1
        return r.to_json
      end

      if async
        # TODO: not optimal
        q.find_each do |o|
          o.confidences.where(confidence_level_id: replace_confidence_level_id).each do |c|
            c.delay(queue: 'query_batch_update').update(confidence_level_id:)
          end
        end
      else
        Confidence
          .where(
            confidence_object_id: q.pluck(:id),
            confidence_object_type: b.referenced_klass.name,
            confidence_level_id: replace_confidence_level_id
          ).update_all(confidence_level_id:)
      end
    when :remove
      # TODO: definitely not optimal, Find is the most expensive, then delete is almost nothing
      if async
        q.find_each do |o|
          Confidence.find_by(confidence_level_id:, confidence_object: o)&.delay(queue: 'query_batch_update').delete
        end
      else
        Confidence
          .where(
            confidence_object_id: q.pluck(:id),
            confidence_object_type: b.referenced_klass.name
          ).delete_all
      end
    when :add
      q.find_each do |o|
        if async
          o.delay(queue: 'query_batch_update').update(confidences_attributes: [{confidence_level_id:, by: Current.user_id, project_id: o.project_id}])
        else
          Confidence.create(confidence_object: o, confidence_level_id:)
        end
      end
    end

    return r.to_json
  end

end
