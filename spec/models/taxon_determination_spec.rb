require 'rails_helper'

describe TaxonDetermination, type: :model do

  let(:taxon_determination) {TaxonDetermination.new}
  let(:otu) { FactoryGirl.create(:valid_otu) }

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


  context "combination of nested attributes and otu_id passes" do
    let(:attributes) { 
      {
        "taxon_determinations_attributes" => [ {
          "otu_id" => otu.to_param, 
          "otu_attributes" => {
            "name" => "",
            "taxon_name_id" => ""
          }
        }
        ]
      }
    }

    let(:specimen) { Specimen.new(attributes)  }

    before { specimen.save }

    specify "both otu_id and empty_otu_attributes works" do
      expect(specimen.taxon_determinations(true).count).to eq(1)
      expect(specimen.otus.to_a).to contain_exactly(otu)
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'has_roles'
    it_behaves_like 'is_data'
  end

end
