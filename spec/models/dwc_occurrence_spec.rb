require 'rails_helper'

describe DwcOccurrence, type: :model, group: :darwin_core do

  # This now creates a dwc_occurrence by default
  let(:collection_object) { FactoryBot.create(:valid_specimen) } 
  let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }

  let(:dwc_occurrence) { DwcOccurrence.new }

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
  end

  specify '#stale? 1' do
    a = collection_object.get_dwc_occurrence
    expect(a.stale?).to be_falsey
  end

  specify '#stale? 2' do
    a = collection_object.get_dwc_occurrence
    a.update!(updated_at: 2.weeks.ago)
    collecting_event.update!(updated_at: 1.week.ago) 
    expect(a.stale?).to be_truthy
  end

  specify '#stale? 3' do
    a = collection_object.get_dwc_occurrence
    a.update!(updated_at: 2.weeks.ago)
    
    b = TaxonDetermination.new(otu: FactoryBot.create(:valid_otu))
    collection_object.taxon_determinations << b
    
    expect(a.stale?).to be_truthy
  end


  # Can't test within a transaction.
  specify '.empty_fields' do
    expect(::DwcOccurrence.empty_fields).to contain_exactly() # Should be ::DwcOccurrence.column_names
  end

  # context 'concerns' do
  # it_behaves_like 'is_data'
  # end

end
