class ProtocolRelationship < ApplicationRecord
  include Housekeeping
  include Shared::BatchByFilterScope
  include Shared::PolymorphicAnnotator
  include Shared::IsData

  polymorphic_annotates(:protocol_relationship_object)

  acts_as_list scope: [:protocol_id, :project_id]

  belongs_to :protocol, inverse_of: :protocol_relationships

  validates :protocol, presence: true
  validates :protocol_id, uniqueness: { scope: [:protocol_relationship_object_id, :protocol_relationship_object_type] }

  def self.process_batch_by_filter_scope(
    batch_response: nil, query: nil, hash_query: nil, mode: nil, params: nil,
    async: nil, project_id: nil, user_id: nil,
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
      if params[:replace_protocol_id].nil?
        r.errors['no replacement protocol provided'] = 1
        return r
      end

      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query: hash_query,
          mode:,
          params:,
          project_id:,
          user_id:
        )
      else
        ProtocolRelationship
          .where(
            protocol_relationship_object_id: query.pluck(:id),
            protocol_relationship_object_type: query.klass.name,
            protocol_id: params[:replace_protocol_id]
          ).find_each do |o|
            o.update(protocol_id: params[:protocol_id])
            if o.valid?
              r.updated.push o.id
            else
              r.not_updated.push o.id
            end
          end
      end

    when :remove
      # Just delete, async or not
      ProtocolRelationship
        .where(
          protocol_relationship_object_id: query.pluck(:id),
          protocol_relationship_object_type: query.klass.name
        ).delete_all

    when :add
      if async && !called_from_async
        BatchByFilterScopeJob.perform_later(
          klass: self.name,
          hash_query: hash_query,
          mode:,
          params:,
          project_id:,
          user_id:
        )
      else
        query.find_each do |o|
          o = ProtocolRelationship.create(protocol_relationship_object: o,
            protocol_id: params[:protocol_id])

          if o.valid?
            r.updated.push o.id
          else
            r.not_updated.push nil
          end
        end
      end

    end

    r
  end

  def dwc_occurrences
    case attribute_subject_type
    when 'FieldOccurrence'
      if protocol_relationship_object.protocols.pluck(&:is_machine_output).uniq == [true] # All protocols are machine, not a mix
        ::DwcOccurrence.where(
          dwc_occurrence_object_type: 'FieldOccurrence',
          dwc_occurrence_object_id: protocol_relationship_object_id)
      end
    else
      ::DwcOccurrence.none
    end
  end

end
