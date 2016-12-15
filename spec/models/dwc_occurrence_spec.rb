require 'rails_helper'

describe DwcOccurrence, type: :model do

  let(:dwc_occurrence) { DwcOccurrence.new }
  let(:collection_object) { FactoryGirl.create(:valid_specimen) } 
  let(:source_person) { Factorygirl.create(:valid_source_person) }
  let(:source_bibtex) { Factorygirl.create(:valid_source_bibtex) }
  let(:asserted_distribution) { FactoryGirl.create(:valid_asserted_distribution) } 

  context 'validation' do
    before { dwc_occurrence.valid? } 
    specify '#basisOfRecord is required' do
      expect(dwc_occurrence.errors.include?(:basisOfRecord)).to be_truthy
    end

    specify 'one of #asserted_distribution or #collection_object is required' do
      expect(dwc_occurrence.errors.include?(:collection_object)).to be_truthy
      expect(dwc_occurrence.errors.include?(:asserted_distribution)).to be_truthy
    end
  end

  context '#basisOfRecord, on validation ' do
    context 'when collection object is provided' do
      before do 
        dwc_occurrence.collection_object = collection_object 
        dwc_occurrence.valid? 
      end

      specify 'is automatically set' do
        expect(dwc_occurrence.basisOfRecord).to eq('PreservedSpecimen')
      end
    end

    context 'when asserted distribution is provided' do
      before { dwc_occurrence.collection_object = asserted_distribution }

      context 'and source is person' do
        before do 
          dwc_occurrence.asserted_distribution.source = source_person
          dwc_occurrence.valid? 
        end

        specify 'is set to "HumanObservation"' do
          expect(dwc_occurrence.basisOfRecord).to eq('HumanObservation')
        end
      end

      context 'and source is bibtex' do
        before do 
          dwc_occurrence.asserted_distribution.source = source_bibtex
          dwc_occurrence.valid? 
        end
       
        specify 'is set to "Occurrence"' do
          expect(dwc_occurrence.basisOfRecord).to eq('Occurrence')
        end
      end

    end
  end


  context 'concerns' do
    # it_behaves_like 'is_data'
  end

end
