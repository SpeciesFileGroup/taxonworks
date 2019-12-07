require 'rails_helper'
describe CollectionObject::DwcExtensions, type: :model, group: :collection_objects do

  context '#dwc_occurrence' do
    let!(:ce) { CollectingEvent.create!(start_date_year: '2010') }
    let!(:s) { Specimen.create!(collecting_event: ce) }


    # Rough tests to detect infinite recursion

    specify 'exists after create' do
      expect(s.dwc_occurrence).to be_truthy
    end    

    specify 'updates after related CE save' do
      ce.update!(start_date_year: 2012)
      expect(s.dwc_occurrence.reload.eventDate).to match('2012')
    end

    specify 'ce save is fine' do
      expect(ce.save).to be_truthy
    end

    specify 'ce update' do
      expect(ce.update(
        "verbatim_label" => "74",
        "roles_attributes" => []
      )).to be_truthy
    end

    specify 'specimen save' do
      expect(s.update!(total: 4)).to be_truthy
    end

    specify 'update dwc_occurrence' do
      d = DwcOccurrence.find(s.dwc_occurrence.id)
      expect(d.update!(year: 2000)).to be_truthy
    end

    context 'with taxon determination' do
      let!(:o) { Otu.create!(name: 'Blob') }
      let!(:td) { TaxonDetermination.create!(biological_collection_object: s, otu: o) }

      specify 'taxon determination udpate' do
        expect(td.update!(otu: FactoryBot.create(:valid_otu))).to be_truthy
      end
    end

    context '2 objects per ce' do
      let(:s2) { Specimen.create!(collecting_event: ce ) }

      specify 'ce.save with 2 specimens' do
        expect(ce.update!(start_date_year: 2012)).to be_truthy
      end

      specify 's2.update' do
        expect(s2.update!(total: 10)).to be_truthy
      end
    end
  end
end

