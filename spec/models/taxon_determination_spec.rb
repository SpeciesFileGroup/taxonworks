require 'spec_helper'

describe TaxonDetermination do

  let(:taxon_determination) {TaxonDetermination.new}

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(taxon_determination).to respond_to(:otu)
      end

      specify 'biological_collection_object' do
        expect(taxon_determination).to respond_to(:biological_collection_object)
      end
    end

    context 'has_one' do
      specify 'determiner' do
        expect(taxon_determination).to respond_to(:determiner)
      end
    end
  end

  specify "if no _made value provided set the deterimination to Time.now" do
    a = FactoryGirl.build(:valid_taxon_determination)
    expect(a.save).to be_true
    expect(a.year_made).to eq(Time.now.year)
    expect(a.month_made).to eq(Time.now.month)
    expect(a.day_made).to eq(Time.now.day)
  end

end
