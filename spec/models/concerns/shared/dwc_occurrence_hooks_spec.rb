require 'rails_helper'

describe 'Shared::DwcOccurrenceHooks', type: :model, group: :dwc_occurrence do
  let!(:hookable_class) {TestDwcHookable.new}

  # TODO: if eager_load paradigm changes this may need update
  ApplicationRecord.descendants.each do |c|
    if c < Shared::DwcOccurrenceHooks

      specify "hooked model includes #dwc_occurrences #{c.name}" do
        expect(c.new.respond_to?(:dwc_occurrences)).to be_truthy
      end

      specify "#dwc_occurrences of #{c.name} is a ActiveRecord::Relation" do
        expect(c.new.dwc_occurrences.class.name).to match('ActiveRecord::Relation')
      end

    end
  end

  context 'running hooks on create, update, delete' do
    let!(:ce) { FactoryBot.create(:valid_collecting_event) }
    let(:co) {
      FactoryBot.create(:valid_collection_object,
        collecting_event: ce, no_dwc_occurrence: false
      )
    }
    let(:fo) {
      FactoryBot.create(:valid_field_occurrence,
        collecting_event: ce
      )
    }

    specify "create 1; hook gets called on a hooked model that doesn't use has_nested_attributes" do
      p = FactoryBot.create(:valid_person, last_name: 'Donut, 13/10')
      Determiner.create!(
        role_object_type: 'TaxonDetermination',
        role_object_id: fo.taxon_determinations.first.id,
        person_id: p.id
      )

      # TODO: use TestDwcHookable so non-has_nested_attributes-ness can be
      # controlled.
      expect(fo.reload.dwc_occurrence.identifiedBy).to match('Donut')
    end

    specify 'create 2; hook gets called on a hooked model that uses has_nested_attributes' do

      Georeference::Leaflet.create!(collecting_event: fo.collecting_event,
        geographic_item_attributes: {
          shape: {
            type: 'Feature', properties: {},
            geometry: {type: 'Point', coordinates: [20, 30]}
          }
        }
      )

      expect(fo.reload.dwc_occurrence.footprintWKT).to match('20 30')
    end

    specify 'update 1' do
      fo.collecting_event.georeferences <<
        FactoryBot.create(:valid_georeference)
      fo.collecting_event.georeferences.first.update!(
        error_radius: 345
      )
      expect(fo.reload.dwc_occurrence.coordinateUncertaintyInMeters)
        .to match('345')
    end

    specify 'update 2; isDwCO object along with nested hooked objects' do
      person = FactoryBot.create(:valid_person, first_name: 'Beevis')

      co.update!(
        total: 3,
        collecting_event_attributes: {
          verbatim_label: 'far far away',
          roles_attributes: [
            { person_id: person.id, type: 'Collector' }
          ]
        }
      )

      co = CollectionObject.first # co is now a Lot
      # Data from the CO update:
      expect(co.dwc_occurrence.individualCount).to eq(3)
      # Data from the CO's nested CE update:
      expect(co.dwc_occurrence.verbatimLabel).to eq('far far away')
      # Data from the CE's nested role create:
      expect(co.dwc_occurrence.recordedBy).to match('Beevis')
    end

    specify 'update 3; updating hooked object linked to multiple DwCOs' do
      [co, fo]
      locality = '11nty hundred and 11'
      ce.update!(verbatim_locality: locality)
      expect(co.reload.dwc_occurrence.verbatimLocality).to eq(locality)
      expect(fo.reload.dwc_occurrence.verbatimLocality).to eq(locality)
    end

    specify 'destroy 1' do
      fo.collecting_event.georeferences <<
        FactoryBot.create(:valid_georeference)
      fo.collecting_event.georeferences.first.destroy!
      expect(fo.reload.dwc_occurrence.footprintWKT).to be_nil
    end

    specify 'destroy 2; hooked object linked to multiple DwCOs' do
      [co, fo]
      _c1 = Collector.create!(
        person: Person.create!(first_name: 'Butter', last_name: 'River'),
        role_object: ce
      )
      c2 = Collector.create!(
        person: Person.create!(first_name: 'Wax', last_name: 'Smith'),
        role_object: ce
      )

      c2.destroy!

      expect(co.reload.dwc_occurrence.recordedBy).to eq('Butter River')
      expect(fo.reload.dwc_occurrence.recordedBy).to eq('Butter River')
    end
  end

  # TODO many (all?) annotator classes like Protocol, Notes, Citations need to
  # be hooked in some way.
  xspecify 'hook gets called on annotator classes' do
    fo.protocols <<
      FactoryBot.create(:valid_protocol, is_machine_output: true)

    expect(fo.reload.dwc_occurrence.basisOfRecord).to match('MachineObservation')
  end
end

class TestDwcHookable < ApplicationRecord
  include FakeTable
  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    DwcOccurrence.none
  end

end
