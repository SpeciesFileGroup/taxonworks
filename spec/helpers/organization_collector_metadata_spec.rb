require 'rails_helper'

RSpec.describe DwcOccurrencesHelper, type: :helper do
  it 'distinguishes people and organizations and respects occurrence scope including field occurrences' do
    person = FactoryBot.create(:valid_person)
    organization = FactoryBot.create(:valid_organization, id: person.id)
    event = FactoryBot.create(:valid_collecting_event)
    event.collector_roles.create!(person:)
    event.collector_roles.create!(organization:)
    occurrence = FactoryBot.create(:valid_field_occurrence, collecting_event: event)
    metadata = helper.collector_global_id_metadata(DwcOccurrence.where(id: occurrence.dwc_occurrence.id), Current.project_id)
    expect(metadata[:without_global_id]).to contain_exactly(["person_#{person.id}", person.cached], ["organization_#{organization.id}", organization.name])
    expect(metadata[:with_global_id]).to be_empty
    expect(helper.collector_global_id_metadata(DwcOccurrence.none, Current.project_id)[:without_global_id]).to be_empty
  end
end
