require 'rails_helper'

describe TaxonWorks::Vendor::Biodiversity, type: :model do
  context 'Result' do

    let(:result) { TaxonWorks::Vendor::Biodiversity::Result.new }

    specify '#name' do
      expect( result.name = 'Aus bus').to be_truthy
    end

    specify '#project_id' do
      expect( result.project_id = 1 ).to be_truthy
    end

    specify '#nomenclature_code' do
      expect( result.nomenclature_code = :icn ).to be_truthy
    end

    context 'parsing' do

      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:genus1) { Protonym.create(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus) ) }
      let!(:species1)  { Protonym.create(name: 'bus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species) ) }
      let!(:species2)  { Protonym.create(name: 'bus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species) ) }

      before do
        result.project_id = 1
      end

      context 'genus species' do
        before do
          result.name = 'Aus bus'
          result.parse
        end 

        specify '#genus' do
          expect(result.genus).to eq('Aus')
        end

        specify '#species' do
          expect(result.species).to eq('bus')
        end

        specify '#detail' do
          expect(result.detail).to eq( { genus: { string: 'Aus'}, species: {string: 'bus'} } )
        end

        specify '#string1' do
          expect(result.string(:genus)).to eq('Aus')
        end

        specify '#string2' do
          expect(result.string(:species)).to eq('bus')
        end

        specify '#parse' do
          expect(result.parse[:scientificName]).to be_truthy
        end

        specify '#result1' do
          expect(result.result[:genus]).to contain_exactly(genus1)
        end

        specify '#result2' do
          expect(result.result[:species]).to contain_exactly(species1, species2)
        end

      end
      context 'mode: grouped' do
        let!(:subgenus) { Protonym.create(name: 'Aus', parent: genus1, rank_class: Ranks.lookup(:iczn, :subgenus) ) }

        before do
          result.name = 'Aus (Aus) bus dus'
          result.parse
        end 

        specify '#subspecies' do
          expect(result.subspecies).to eq('dus') 
        end

        specify '#subgenus' do
          expect(result.subgenus).to eq('Aus') 
        end

        specify '#result1' do
          expect(result.result[:genus]).to contain_exactly(genus1, subgenus)
        end

        specify '#result2' do
          expect(result.result[:subgenus]).to contain_exactly(genus1, subgenus)
        end
      end
    end

  end

end 





