require 'rails_helper'

describe TaxonDetermination, type: :model do

  let(:taxon_determination) {TaxonDetermination.new}
  let(:otu) { FactoryGirl.create(:valid_otu) }
  let(:specimen) { Specimen.new()  }

  let(:nested_attributes) { 
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

  context 'acts_as_list ordering of determinations' do
    let(:otu1) { FactoryGirl.create(:valid_otu) }
    let(:otu2) { FactoryGirl.create(:valid_otu) }

    before { 
      specimen.save!
      specimen.taxon_determinations << TaxonDetermination.new(otu: otu)
    }

    specify 'terminations are added to the bottom of the stack' do
      t = TaxonDetermination.new(otu: otu1) 
      specimen.taxon_determinations << t
      expect(specimen.taxon_determinations.last.otu).to eq(otu1)
    end

    specify 'move a determination to the preferred slot with #move_to_top' do
      t = TaxonDetermination.new(otu: otu1) 
      specimen.taxon_determinations << t
      specimen.taxon_determinations.last.move_to_top
      expect(specimen.current_taxon_determination.otu).to eq(otu1)
    end

  end

  context 'nested taxon determinations' do
    context 'combination of nested attributes and otu_id passes' do
      let(:s) { Specimen.create(nested_attributes) }

      specify "both otu_id and empty_otu_attributes works" do
        expect(s.taxon_determinations(true).count).to eq(1)
        expect(s.otus.to_a).to contain_exactly(otu)
      end
    end

    context 'empty otu_id' do
      let(:a) {
        {
          "otu_id" => ""
        }
      }

      specify 'does not raise or create' do
        expect(Specimen.create(taxon_determinations_attributes: [a])).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'has_roles'
    it_behaves_like 'is_data'
  end

end
