# Occurrences whose collector or determiner roles use this agent.
module Shared::DwcRoleAgent
  extend ActiveSupport::Concern

  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    Shared::DwcRoleAgent.occurrences_for(self)
  end

  def self.occurrences_for(agent)
    events = agent.roles.where(type: 'Collector', role_object_type: 'CollectingEvent').select(:role_object_id)
    determinations = TaxonDetermination.where(id: agent.roles.where(type: 'Determiner', role_object_type: 'TaxonDetermination').select(:role_object_id))

    scopes = [CollectionObject, FieldOccurrence].map do |model|
      determined_ids = determinations.where(taxon_determination_object_type: model.name).select(:taxon_determination_object_id)
      objects = model.where(collecting_event_id: events).or(model.where(id: determined_ids))
      DwcOccurrence.where(dwc_occurrence_object_type: model.name, dwc_occurrence_object_id: objects.select(:id))
    end
    ::Queries.union(DwcOccurrence, scopes)
  end
end
