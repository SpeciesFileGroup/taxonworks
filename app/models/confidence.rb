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
  include Shared::BatchByFilterScope
  include Shared::Citations
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:confidence_object)

  acts_as_list scope: [:confidence_object_id, :confidence_object_type, :project_id]

  belongs_to :confidence_level, inverse_of: :confidences, validate: true
  belongs_to :controlled_vocabulary_term, foreign_key: :confidence_level_id, inverse_of: :confidences

  validates :confidence_level, presence: true
  validates :confidence_level_id, uniqueness: { scope: [:confidence_object_id, :confidence_object_type] }

  accepts_nested_attributes_for :confidence_level, allow_destroy: true

  def self.exists?(global_id, confidence_level_id, project_id)
    o = GlobalID::Locator.locate(global_id)
    return false unless o
    Confidence.where(project_id: project_id, confidence_object: o, confidence_level_id: confidence_level_id).first
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
      # TODO: Return response
      if params[:replace_confidence_level_id].nil?
        r.errors['no replacement confidence level provided'] = 1
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
        Confidence
          .where(
            confidence_object_id: query.pluck(:id),
            confidence_object_type: query.klass.name,
            confidence_level_id: params[:replace_confidence_level_id]
          ).find_each do |o|
            o.update(confidence_level_id: params[:confidence_level_id])
            if o.valid?
              r.updated.push o.id
            else
              r.not_updated.push o.id
            end
          end
      end

    when :remove
      # Just delete, async or not
      Confidence
        .where(
          confidence_object_id: query.pluck(:id),
          confidence_object_type: query.klass.name,
          confidence_level_id: params[:confidence_level_id]
        ).delete_all

    when :add
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
        query.find_each do |o|
          o = Confidence.create(
            confidence_object: o,
            confidence_level_id: params[:confidence_level_id]
          )

          if o.valid?
            r.updated.push o.id
          else
            r.not_updated.push o.id
          end
        end
      end

    end

    return r
  end

end
