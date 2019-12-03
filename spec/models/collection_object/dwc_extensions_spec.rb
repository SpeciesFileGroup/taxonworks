require 'rails_helper'
describe CollectionObject::DwcExtensions, type: :model, group: :collection_objects do


  context '#dwc_occurrence' do
    let!(:ce) { CollectingEvent.create!(start_date_year: '2010') }
    let!(:s) { Specimen.create!(collecting_event: ce) }
       
    specify 'exists after create' do
      expect(s.dwc_occurrence).to be_truthy
    end    
  end

end

