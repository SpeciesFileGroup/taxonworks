require 'rails_helper'

describe CollectingEvent, type: :model, group: [:geo, :collecting_events] do

  let(:collecting_event) { CollectingEvent.new }
  let(:county) { FactoryBot.create(:valid_geographic_area_stack) }
  let(:state) { county.parent }
  let(:country) { state.parent }

  context 'when #no_cached = true' do
    before do 
      collecting_event.no_cached = true
      collecting_event.save!
    end
    
    specify 'nothing is cached' do
      expect(collecting_event.cached.blank?).to be_truthy
    end

    specify 'when Roles created nothing is cached' do
      collecting_event.collectors << [ FactoryBot.create(:valid_person), FactoryBot.create(:valid_person) ]
      expect(collecting_event.cached).to eq(nil)
    end

    specify 'when Georeference created nothing is cached' do
      collecting_event.georeferences << FactoryBot.build(:valid_georeference)
      expect(collecting_event.georeferences.reload.count).to eq(1)
      expect(collecting_event.cached).to eq(nil)
    end
  end

  context 'when #no_cached = false, nil' do
    specify 'after save with no data cached is *not* blank?' do
      collecting_event.save!
      expect(collecting_event.cached.blank?).to be_falsey, collecting_event.cached
    end

    context 'contents of cached' do
      context 'with geographic_area set' do
        before{
          collecting_event.save!
          collecting_event.update_attribute(:geographic_area_id, county.id)
        }

        specify 'summarized in first line' do
          expect(collecting_event.cached).to eq('United States: Illinois: Champaign')
        end
      end

      specify 'just dates' do
        collecting_event.start_date_day   = 1
        collecting_event.start_date_month = 1
        collecting_event.start_date_year  = 1511

        collecting_event.end_date_day   = 2
        collecting_event.end_date_month = 2
        collecting_event.end_date_year  = 1522

        collecting_event.save!
        expect(collecting_event.cached.blank?).to be_falsey
        expect(collecting_event.cached.strip).to eq('1511/01/01-1522/02/02')
      end

      specify 'just start date' do
        collecting_event.start_date_day   = 1
        collecting_event.start_date_month = 1
        collecting_event.start_date_year  = 1511

        collecting_event.save!
        expect(collecting_event.cached.blank?).to be_falsey
        expect(collecting_event.cached.strip).to eq('1511/01/01')
      end

      specify 'just verbatim_label' do
        collecting_event.verbatim_label = 'Just this thing.'

        collecting_event.save!
        expect(collecting_event.cached.blank?).to be_falsey
        expect(collecting_event.cached.strip).to eq('Just this thing.')
      end
    end
  end
end
