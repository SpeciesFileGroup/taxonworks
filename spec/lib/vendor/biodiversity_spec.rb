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
      let!(:species1) { Protonym.create(name: 'bus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species) ) }

      before do
        result.project_id = 1
      end

      context 'existing matches' do
        before do
          result.name = 'Aus bus Smith and Jones, 1920'
          result.parse
          result.build_result
        end
        
        specify '#combination_exists? 1' do
          expect(result.combination_exists?).to eq(false)
        end

        specify '#combination_exists? 1' do
          c = Combination.create!(genus: genus1, species: species1)
          expect(result.combination_exists?).to eq(c)
        end
      end

      context 'unambiguous' do
        before do
          result.name = 'Aus bus Smith and Jones, 1920'
          result.parse
          result.build_result
        end

        let(:combination) { result.combination }

        specify 'genus' do
          expect(result.genus).to eq('Aus') 
        end

        specify '#protonym_result' do
          expect(result.protonym_result[:genus]).to include(genus1)
        end

        specify '#preparse' do
          expect(result.preparse).to contain_exactly(result.name)
        end
        
        specify '#is_unambiguous?' do
          expect(result.is_unambiguous?).to eq(true)
        end

        specify '#finest_rank' do
          expect(result.finest_rank). to eq(:species)
        end

        specify '#combination genus' do
          expect(combination.genus_id).to eq(genus1.id)
        end

        specify '#combination species' do
          expect(combination.species_id).to eq(species1.id)
        end

        specify '#grouped_protonyms1' do
          expect(result.grouped_protonyms(:species)).to contain_exactly(species1)
        end

        context 'match author year' do
          let!(:species3) { Protonym.create(
            name: 'bus',
            year_of_publication: '1920', 
            verbatim_author: 'Smith and Jones',
            parent: genus1, 
              rank_class: Ranks.lookup(:iczn, :species) 
          ) }

          before do
            result.name = 'Aus bus Smith and Jones, 1920'
            result.parse
            result.build_result
          end

          specify '#is_unambiguous? (still)' do
            expect(result.is_unambiguous?).to eq(true)
          end

          specify '#grouped_protonyms1' do
            expect(result.grouped_protonyms(:species)).to contain_exactly(species3)
          end
        end 
      end

      context 'species with ambiguity' do

        let!(:species2)  { Protonym.create(
          name: 'bus', 
          parent: genus1, 
          rank_class: Ranks.lookup(:iczn, :species) 
        ) }

        context 'without author checks' do
          before do
            result.name = 'Aus bus Smith and Jones, 1920'
            result.parse
            result.build_result
          end

          specify '#is_authored?' do
            expect(result.is_authored?).to eq(true)
          end

          specify '#is_unambiguous?' do
            expect(result.is_unambiguous?).to eq(false)
          end 

          specify 'result[:unambiguous]' do
            expect(result.result[:unambiguous]).to eq(false)
          end

          specify '#genus' do
            expect(result.genus).to eq('Aus')
          end

          specify '#species' do
            expect(result.species).to eq('bus')
          end

          specify '#author' do
            expect(result.author).to eq('Smith & Jones')
          end

          specify '#year' do
            expect(result.year).to eq('1920')
          end

          specify '#detail' do
            expect(result.detail).to include( { 
              genus: { string: 'Aus'},
              species: {
                string: 'bus', 
                authorship: 'Smith and Jones, 1920',
                basionymAuthorTeam: {
                  authorTeam: 'Smith and Jones', 
                  author: ['Smith', 'Jones'], 
                  year: '1920'}
              }
            }) 
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

          context 'protonyms' do
            specify '#result1' do
              expect(result.result[:protonyms][:genus]).to contain_exactly(genus1)
            end

            specify '#result2' do
              expect(result.result[:protonyms][:species]).to contain_exactly(species1, species2)
            end
          end
        end
      end

      context 'mode: grouped' do
        let!(:subgenus) { Protonym.create(name: 'Aus', parent: genus1, rank_class: Ranks.lookup(:iczn, :subgenus) ) }

        before do
          result.name = 'Aus (Aus) bus dus'
          result.parse
          result.build_result
        end 

        specify '#subspecies' do
          expect(result.subspecies).to eq('dus') 
        end

        specify '#subgenus' do
          expect(result.subgenus).to eq('Aus') 
        end

        specify '#result1' do
          expect(result.result[:protonyms][:genus]).to contain_exactly(genus1, subgenus)
        end

        specify '#result2' do
          expect(result.result[:protonyms][:subgenus]).to contain_exactly(genus1, subgenus)
        end

        specify '#combination' do
          c = result.combination
          expect(c.genus_id).to eq(nil)
          expect(c.subgenus_id).to eq(nil)
        end
      end
    end

    context 'an unmatched result' do
      before do
        result.name = 'Zzus (Arg) plort plurt Walbert, Nordberg and Zarf, 2017'
        result.parse
        result.build_result
      end

      context 'result[:parse]' do
        specify '#result1' do
          expect(result.result[:parse][:genus]).to eq('Zzus')
        end

        specify '#result2' do
          expect(result.result[:parse][:subgenus]).to eq('Arg')
        end

        specify '#result3' do
          expect(result.result[:parse][:species]).to eq('plort')
        end

        specify '#result4' do
          expect(result.result[:parse][:subspecies]).to eq('plurt')
        end
      end
    end

  end
end 





