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

  def self.batch_by_filter_scope(filter_query: nil, confidence_level_id: nil, replace_confidence_level_id: nil, mode: :add, async_cutoff: 300, project_id: nil, user_id: nil)
    r = ::BatchResponse.new(
      preview: false,
      method: 'Confidence batch_by_filter_scope',
    )

    if filter_query.nil?
      r.errors['scoping filter not provided'] = 1
      return r
    end

    b = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
    q = b.all(true)

    r.klass =  b.referenced_klass.name

    if b.only_project?
      r.total_attempted = 0
      r.errors['can not update records without at least one filter parameter'] = 1
      return r
    else
      c = q.count
      async = c > async_cutoff ? true : false

      r.total_attempted = c
      r.async = async
    end

    case mode.to_sym
    when :replace
      # TODO: Return response
      if replace_confidence_level_id.nil?
        r.errors['no replacement confidence level provided'] = 1
        return r.to_json
      end

      if async
        ConfidenceBatchJob.perform_later(
          filter_query:,
          confidence_level_id:,
          replace_confidence_level_id:,
          mode: :replace,
          project_id:,
          user_id:,
        )
      else
        Confidence
          .where(
            confidence_object_id: q.pluck(:id),
            confidence_object_type: b.referenced_klass.base_class.name,
            confidence_level_id: replace_confidence_level_id
          ).find_each do |o|
            o.update(confidence_level_id:)
          end
      end
    when :remove
      # Just delete, async or not
      Confidence
        .where(
          confidence_object_id: q.pluck(:id),
          confidence_object_type: b.referenced_klass.name
        ).delete_all
    when :add
      if async
        ConfidenceBatchJob.perform_later(
          filter_query:,
          confidence_level_id:,
          replace_confidence_level_id:,
          mode: :add,
          project_id:,
          user_id:,
        )
      else
        q.find_each do |o|
          Confidence.create(confidence_object: o, confidence_level_id:)
        end
      end

    end

    return r.to_json
  end



end
