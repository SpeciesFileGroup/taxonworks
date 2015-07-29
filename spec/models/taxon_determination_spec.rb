require 'rails_helper'

describe TaxonDetermination, :type => :model do

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

    context 'has_many' do
      specify 'determiners' do
        expect(taxon_determination).to respond_to(:determiners)
      end
    end
  end

  specify "if no _made value provided set the deterimination to Time.now" do
    a = FactoryGirl.build(:valid_taxon_determination)
    expect(a.save).to be_truthy
    expect(a.year_made).to eq(Time.now.year)
    expect(a.month_made).to eq(Time.now.month)
    expect(a.day_made).to eq(Time.now.day)
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'has_roles'
    it_behaves_like 'is_data'
  end

end
