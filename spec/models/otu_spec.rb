require 'spec_helper'

describe Otu do

  let(:otu) { Otu.new }
  before(:all) do
    TaxonName.delete_all
  end

  after(:all) do
    TaxonNameRelationship.delete_all
  end

  # foreign key relationships
  context 'reflections / foreign keys' do
    context 'has many' do
      specify 'taxon determinations' do
        expect(otu).to respond_to(:taxon_determinations)
        expect(otu.taxon_determinations).to eq([])
      end

      specify 'contents' do
        expect(otu).to respond_to(:contents)
      end

      specify 'topics' do
        expect(otu).to respond_to(:topics)
      end
    end
  end

  context 'properties' do
    specify 'name' do
      expect(otu).to respond_to(:name)
    end
  end

  context 'validation' do
    specify 'otu without name and without taxon_name_id is invalid' do
      expect(otu.valid?).to be_false
    end
    specify 'otu should require a name or taxon_name_id' do
      otu.soft_validate(:taxon_name)
      expect(otu.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
    end
  end

  context 'when I create a new OTU' do
    context 'and it only has taxon_name_id populated' do
      specify 'its otu_name should be the taxon name cached_name' do
        expect(otu.otu_name).to eq(nil)

        t = FactoryGirl.create(:relationship_species)
        t.reload
        expect(t.valid?).to be_true

        otu.taxon_name = t
        expect(otu.otu_name).to eq('<em>Erythroneura vitis</em> McAtee, 1900')

        otu.name = 'Foo'
        expect(otu.otu_name).to eq('Foo')
      end
    end
    context 'new otu with the same taxon_name' do
      specify 'otu names should be unique' do
        otu1 = FactoryGirl.create(:valid_otu, name: 'aaa')
        expect(otu1.valid?).to be_true
        otu2 = FactoryGirl.build_stubbed(:valid_otu, name: 'aaa')
        expect(otu2.valid?).to be_false
        otu2.taxon_name_id = 1
        expect(otu2.valid?).to be_true
      end
    end
  end



  context 'concerns' do
    # it_behaves_like 'citable' # => maybe  
    it_behaves_like 'identifiable'
    it_behaves_like 'data_attributes'
    it_behaves_like 'taggable'
    it_behaves_like 'alternate_values'
  end
end
