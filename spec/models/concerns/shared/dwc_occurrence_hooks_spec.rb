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

  context 'CUD' do
    let(:fo) { FactoryBot.create(:valid_field_occurrence) }

    before(:each) {
      Georeference::Leaflet.create!(collecting_event: fo.collecting_event,
        geographic_item_attributes: {
          shape: {
            type: 'Feature', properties: {},
            geometry: {type: 'Point', coordinates: [20, 30]}
          }
        }
      )
    }

    specify 'hook gets called on a hooked model that uses has_nested_attributes' do
      # Using the hook `after_save :process_dwc_occurrences, if:
      # :saved_changes?` fails in this case because(?) the nested create causes
      # a nested save on create, which causes saved_changes? to be empty in
      # after_save_commit.
      expect(fo.reload.dwc_occurrence.footprintWKT).to match('20 30')
    end

    # TODO FO's CE gets created/updated through georefs/collectors etc.

    # TODO many (all?) annotator classes like Protocol, Notes, Citations need to
    # be hooked in some way.
    xspecify 'hook gets called on annotator classes' do
      fo.protocols <<
        FactoryBot.create(:valid_protocol, is_machine_output: true)

      expect(fo.reload.dwc_occurrence.basisOfRecord).to match('MachineObservation')
    end

    specify "hook gets called on a hooked model that doesn't use has_nested_attributes" do
      # Using FactoryBot doesn't trigger after_save on Determiner.
      #determiner = FactoryBot.create(:valid_determiner,
      #  role_object_type: 'TaxonDetermination',
      #  role_object_id: fo.taxon_determinations.first.id
      #)
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

    specify 'update' do
      fo.collecting_event.georeferences.first.update!(
        error_radius: 345
      )
      expect(fo.reload.dwc_occurrence.coordinateUncertaintyInMeters)
        .to match('345')
    end
  end
end

class TestDwcHookable < ApplicationRecord
  include FakeTable
  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    DwcOccurrence.none
  end

end
