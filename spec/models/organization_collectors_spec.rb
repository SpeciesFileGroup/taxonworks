require 'rails_helper'

RSpec.describe 'Organization collectors and determiners' do
  include ActiveJob::TestHelper

  before { allow(Wikidata::Item).to receive(:find).and_return(true) }

  let(:organization) { FactoryBot.create(:valid_organization, name: 'Museum collecting team') }
  let(:person) { Person.find(FactoryBot.create(:valid_person).id) }
  let(:event) { FactoryBot.create(:valid_collecting_event) }

  def add_collectors
    event.collector_roles.create!(organization:, position: 1)
    event.collector_roles.create!(person:, position: 2)
  end

  it 'keeps ordered agents, people-only collectors, inverses and clones' do
    add_collectors
    expect(event.collector_roles.order(:position).map(&:agent)).to eq([organization, person])
    expect(event.collectors).to eq([person])
    expect(event.collectors_organization).to eq([organization])
    expect(organization.collecting_events).to include(event)
    expect(event.clone.collector_roles.order(:position).map { |role| role.agent.name }).to eq([organization.name, person.name])
    expect(event.collector_names).to eq("#{organization.name} & #{person.last_name}")
    expect(event.collector_roles.build(organization:)).not_to be_valid
    expect(event.collector_roles.build(organization:, person:)).not_to be_valid
  end

  it 'recognizes organization-only collectors in presence filters and summaries' do
    event.collector_roles.create!(organization:)
    specimen = Specimen.create!(collecting_event: event)
    expect(event.has_collectors?).to be true
    expect(specimen.dwc_occurrence.recordedBy).to eq(organization.name)
    expect(Queries::CollectingEvent::Filter.new(collectors: true).all).to include(event)
    expect(Queries::CollectingEvent::Filter.new(collectors: false).all).not_to include(event)
    expect(Queries::CollectingEvent::Filter.new(collector_id: [organization.id]).all).not_to include(event)
    expect(Queries::CollectionObject::Filter.new(collectors: true).all).to include(specimen)
    expect(Queries::CollectionObject::Filter.new(collectors: false).all).not_to include(specimen)
    expect(ApplicationController.helpers.collecting_event_collectors_tag(event)).to include(organization.name)
    expect(ApplicationController.helpers.role_tag(event.collector_roles.first)).to include(organization.name)
    expect(ApplicationController.helpers.roles_names(event.collector_roles)).to eq(organization.name)
    expect(ApplicationController.helpers.collecting_event_graph(event).to_json[:nodes]).to include(hash_including(name: organization.name))
  end

  it 'preserves ordering and names for unsaved mixed collector roles' do
    person = FactoryBot.create(:valid_person, last_name: 'Smith')
    unsaved_event = CollectingEvent.new
    organization_role = unsaved_event.collector_roles.build(organization:, position: 2)
    unsaved_event.collector_roles.build(person:, position: 1)
    specimen = Specimen.new(collecting_event: unsaved_event)

    expect(unsaved_event.collector_names).to eq("#{person.last_name} & #{organization.name}")
    summary = ApplicationController.helpers.collecting_event_collectors_tag(unsaved_event)
    expect(summary).to include("#{person.cached} &amp; #{organization.name}")
    expect(specimen.dwc_recorded_by).to eq([person.name, organization.name].join(Export::Dwca::DELIMITER))

    organization_role.position = nil
    expect(unsaved_event.collector_names).to eq("#{person.last_name} & #{organization.name}")
    expect(specimen.dwc_recorded_by).to eq([person.name, organization.name].join(Export::Dwca::DELIMITER))
  end

  [Specimen, FieldOccurrence].each do |model|
    context model.name do
      let(:occurrence) do
        model == Specimen ? Specimen.create!(collecting_event: event) : FactoryBot.create(:valid_field_occurrence, collecting_event: event)
      end

      it 'exports ordered agents and identifiers, and refreshes on organization and role changes' do
        add_collectors
        occurrence
        id = Identifier::Global::Wikidata.create!(identifier_object: organization, identifier: 'Q123')
        perform_enqueued_jobs
        expect(occurrence.dwc_occurrence.reload.recordedByID).to eq(id.cached)
        expect(occurrence.dwc_recorded_by).to eq([organization.name, person.name].join(Export::Dwca::DELIMITER))
        expect(occurrence.dwc_recorded_by_id).to eq(id.cached)
        td = occurrence.current_taxon_determination || FactoryBot.create(:valid_taxon_determination, taxon_determination_object: occurrence)
        td.determiner_roles.create!(organization:, position: 1)
        td.determiner_roles.create!(person:, position: 2)
        occurrence.reload
        expect(occurrence.dwc_identified_by).to eq([organization.name, person.name].join(Export::Dwca::DELIMITER))
        expect(occurrence.dwc_identified_by_id).to eq(id.cached)
        expect(id.dwc_occurrences).to include(occurrence.dwc_occurrence)
        organization.update!(name: 'Renamed museum')
        perform_enqueued_jobs
        expect(occurrence.dwc_occurrence.reload.recordedBy).to start_with('Renamed museum')
        expect(occurrence.dwc_occurrence.identifiedBy).to start_with('Renamed museum')
        archive = Export::Dwca::Occurrence::Data.new(core_scope: DwcOccurrence.where(id: occurrence.dwc_occurrence.id))
        begin
          Zip::File.open(archive.zipfile.path) do |zip|
            row = CSV.parse(zip.read('data.tsv'), headers: true, col_sep: "\t").first
            expect(row['recordedBy']).to eq(['Renamed museum', person.name].join(Export::Dwca::DELIMITER))
            expect(row['identifiedBy']).to eq(['Renamed museum', person.name].join(Export::Dwca::DELIMITER))
            expect(row['recordedByID']).to eq(id.cached)
            expect(row['identifiedByID']).to eq(id.cached)
          end
        ensure
          archive.cleanup
        end
        id.update!(identifier: 'Q124')
        perform_enqueued_jobs
        expect(occurrence.dwc_occurrence.reload.identifiedByID).to eq('Q124')
        id.destroy!
        perform_enqueued_jobs
        expect(occurrence.dwc_occurrence.reload.recordedByID).to be_nil
        expect(occurrence.dwc_occurrence.identifiedByID).to be_nil
        event.collector_roles.where(organization:).first.destroy!
        perform_enqueued_jobs
        expect(occurrence.dwc_occurrence.reload.recordedBy).to eq(person.name)
        td.determiner_roles.where(organization:).first.destroy!
        perform_enqueued_jobs
        expect(occurrence.dwc_occurrence.reload.identifiedBy).to eq(person.name)
      end
    end
  end

  it 'orders mixed identifiers and scopes person determiner refreshes to their occurrences' do
    add_collectors
    specimen = Specimen.create!(collecting_event: event)
    unrelated = Specimen.create!
    person_id = Identifier::Global::Wikidata.create!(identifier_object: person, identifier: 'Q125')
    organization_id = Identifier::Global::Wikidata.create!(identifier_object: organization, identifier: 'Q123')
    expect(specimen.dwc_recorded_by_id).to eq([organization_id.cached, person_id.cached].join(Export::Dwca::DELIMITER))
    # Exercise the determiner route independently of collecting events and identifier IDs.
    determination = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: unrelated)
    determination.determiner_roles.create!(person:)
    expect(person_id.dwc_occurrences).to contain_exactly(specimen.dwc_occurrence, unrelated.dwc_occurrence)
    expect(organization_id.dwc_occurrences).to contain_exactly(specimen.dwc_occurrence)
    Identifier.find(person_id.id).update!(identifier: 'Q126')
    perform_enqueued_jobs
    expect(unrelated.dwc_occurrence.reload.identifiedByID).to eq('Q126')
  end

  it 'falls back to verbatim collectors when no agents remain' do
    event.update!(verbatim_collectors: 'Field expedition')
    specimen = Specimen.create!(collecting_event: event)
    expect(specimen.dwc_recorded_by).to eq('Field expedition')
  end
end
