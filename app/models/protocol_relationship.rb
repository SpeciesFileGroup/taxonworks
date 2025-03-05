class ProtocolRelationship < ApplicationRecord
  include Housekeeping
  include Shared::PolymorphicAnnotator
  include Shared::IsData

  polymorphic_annotates(:protocol_relationship_object)

  acts_as_list scope: [:protocol_id, :project_id]

  belongs_to :protocol, inverse_of: :protocol_relationships

  validates :protocol, presence: true
  validates_uniqueness_of :protocol_id, scope: [:protocol_relationship_object_id, :protocol_relationship_object_type]

  # TODO: See parallel logic in Confidence batch.
  def self.batch_by_filter_scope(filter_query: nil, protocol_id: nil, replace_protocol_id: nil, mode: :add, async_cutoff: 300, project_id: nil, user_id: nil)
    r = ::BatchResponse.new(
      preview: false,
      method: 'Protocol relationship batch_by_filter_scope',
    )

    if filter_query.nil?
      r.errors['scoping filter not provided'] = 1
      return r
    end

    b = ::Queries::Query::Filter.instantiated_base_filter(filter_query)
    q = b.all(true)

    fq = ::Queries::Query::Filter.base_query_to_h(filter_query)

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
      if replace_protocol_id.nil?
        r.errors['no replacement protocol provided'] = 1
        return r.to_json
      end

      if async
        ProtocolRelationshipBatchJob.perform_later(
          filter_query: fq,
          protocol_id:,
          replace_protocol_id:,
          mode: :replace,
          project_id:,
          user_id:,
        )
      else
        ProtocolRelationship
          .where(
            protocol_relationship_object_id: q.pluck(:id),
            protocol_relationship_object_type: b.referenced_klass.base_class.name,
            protocol_id: replace_protocol_id
          ).find_each do |o|
            o.update(protocol_id:)
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
          protocol_relationship_object_id: q.pluck(:id),
          protocol_relationship_object_type: b.referenced_klass.name
        ).delete_all
    when :add
      if async
        ProtocolRelationshipBatchJob.perform_later(
          filter_query: fq,
          protocol_id:,
          replace_protocol_id:,
          mode: :add,
          project_id:,
          user_id:,
        )
      else
        q.find_each do |o|
          o = ProtocolRelationship.create(protocol_relationship_object: o, protocol_id:)
        
          if o.valid? 
            r.updated.push o.id
          else
            r.not_updated.push o.id
          end
        end
      end

    end

    return r.to_json
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
