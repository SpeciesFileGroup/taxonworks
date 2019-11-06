require 'rails_helper'

describe DwcOccurrence, type: :model, group: :darwin_core do

  let(:dwc_occurrence) { DwcOccurrence.new }
  let(:collection_object) { FactoryBot.create(:valid_specimen) } 
  let(:source_human) { FactoryBot.create(:valid_source_human) }
  let(:source_bibtex) { FactoryBot.create(:valid_source_bibtex) }
  let(:asserted_distribution) { FactoryBot.create(:valid_asserted_distribution) } 

  context 'validation' do
    context 'with a new instance' do
      before { dwc_occurrence.valid? } 

      # specify '#basisOfRecord is required' do
      #   expect(dwc_occurrence.errors.include?(:basisOfRecord)).to be_truthy
      # end

      specify '#dwc_occurrence_object is required' do
        expect(dwc_occurrence.errors.include?(:dwc_occurrence_object)).to be_truthy
      end
    end

    context 'the referenced TW' do
      let(:new_dwc_occurrence) { DwcOccurrence.new }

      context '#collection_object' do      
        before do
          dwc_occurrence.dwc_occurrence_object = collection_object
          dwc_occurrence.save
          new_dwc_occurrence.dwc_occurrence_object = collection_object
          new_dwc_occurrence.valid?
        end

        specify 'occurs only once' do
          expect(new_dwc_occurrence.errors.include?(:dwc_occurrence_object_id)).to be_truthy
        end
      end
    end
  end

  context '#basisOfRecord, on validation ' do
    context 'when collection object is provided' do
      before do 
        dwc_occurrence.dwc_occurrence_object = collection_object 
        dwc_occurrence.valid? 
      end

      specify 'is automatically set' do
        expect(dwc_occurrence.basisOfRecord).to eq('PreservedSpecimen')
      end
    end

    context 'when asserted distribution is provided' do
      before { dwc_occurrence.dwc_occurrence_object = asserted_distribution }

      context 'and source is person' do
        before do 
          dwc_occurrence.dwc_occurrence_object.source = source_human
          dwc_occurrence.valid? 
        end

        specify 'is set to "HumanObservation"' do
          expect(dwc_occurrence.basisOfRecord).to eq('HumanObservation')
        end
      end

      context 'and source is bibtex' do
        before do 
          dwc_occurrence.dwc_occurrence_object.source = source_bibtex
          dwc_occurrence.valid? 
        end

        specify 'is set to "Occurrence"' do
          expect(dwc_occurrence.basisOfRecord).to eq('Occurrence')
        end
      end
    end

    context 'helper methods' do
      before do
        dwc_occurrence.dwc_occurrence_object = collection_object
        dwc_occurrence.save!
      end
      specify '#stale?' do
        expect(dwc_occurrence.stale?).to be_falsey
      end
    end
  end

  # context 'concerns' do
  # it_behaves_like 'is_data'
  # end

end
