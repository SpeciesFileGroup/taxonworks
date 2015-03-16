require 'rails_helper'

describe Otu, :type => :model do

  let(:otu) { Otu.new }
  before(:all) do
    TaxonName.delete_all
  end

  after(:all) do
    TaxonNameRelationship.delete_all
  end

  # foreign key relationships
  context 'associations' do
    context 'has many' do
      specify 'taxon determinations' do
        expect(otu.taxon_determinations << TaxonDetermination.new).to be_truthy
      end

      specify 'contents' do
        expect(otu.contents << Content.new).to be_truthy
      end

      specify 'topics' do
        expect(otu.topics << Topic.new).to be_truthy
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
      expect(otu.valid?).to be_falsey
    end
    specify 'otu should require a name or taxon_name_id' do
      otu.soft_validate(:taxon_name)
      expect(otu.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
    end
    specify 'duplicate OTU' do
      o1 = FactoryGirl.create(:otu, name: 'Aus')
      o2 = FactoryGirl.build_stubbed(:otu, name: 'Aus')
      o1.soft_validate(:duplicate_otu)
      expect(o1.soft_validations.messages_on(:taxon_name_id).empty?).to be_truthy
      o2.soft_validate(:duplicate_otu)
      expect(o2.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
    end
  end

  context 'when I create a new OTU' do
    context 'and it only has taxon_name_id populated' do
      specify 'its otu_name should be the taxon name cached_html' do
        expect(otu.otu_name).to eq(nil)

        t = FactoryGirl.create(:relationship_species)
        t.reload
        expect(t.valid?).to be_truthy

        otu.taxon_name = t
        expect(otu.otu_name).to eq('<em>Erythroneura vitis</em> McAtee, 1900')

        otu.name = 'Foo'
        expect(otu.otu_name).to eq('Foo')
      end
    end
  end


  context 'batch loading' do
    let(:file) {
      f = File.new('/tmp/temp', 'w+')
      str = CSV.generate do |csv|
        csv << ["Aus"]
        csv << ["Bus"]
        csv << [nil]
        csv << ["Cus"]
      end
      f.write str
      f.rewind
      f
    }

    context '.batch_preview' do
      specify '.batch_preview takes a file argument' do
        expect(Otu.batch_preview(file: file)).to be_truthy
      end

      specify '.batch_preview takes hash of arguments' do
        hsh = {file: file, stuff: :things}
        expect(Otu.batch_preview(hsh)).to be_truthy
      end

      specify '.batch_preview returns an Array' do
        expect(Otu.batch_preview(file: file).class).to eq(Array)
      end

      specify '.batch_preview ignores blank lines' do
        expect(Otu.batch_preview(file: file).count).to eq(3)
      end

      specify '.batch_preview takes the first row as headers' do
        expect(Otu.batch_preview(file: file).count).to eq(3)
      end

      specify 'returns Otus' do
        expect(Otu.batch_preview(file: file).first.class).to eq(Otu)
      end

      specify 'returns Otus with names' do
        expect(Otu.batch_preview(file: file).first.name).to eq('Aus')
      end
    end

    context '.batch_create' do
      let(:params) {
        {otus:
             {'1' => {'name' => 'Aus'},
              '2' => {'name' => 'Bus'}}
        }
      }

      specify 'returns an array' do
        expect(Otu.batch_create(params).class).to eq(Array)
      end

      specify 'returns an array of Otus' do
        expect(Otu.batch_create(params).first.class).to eq(Otu)
      end

      specify 'returns named Otus' do
        expect(Otu.batch_create(params).first.name).to eq('Aus')
      end

      specify 'returns multiple Otus' do
        expect(Otu.batch_create(params).count).to eq(2)
      end

    end

  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end
end
