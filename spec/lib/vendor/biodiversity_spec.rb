require 'rails_helper'

describe ::TaxonWorks::Vendor::Biodiversity, type: :model, group: [:nomenclature] do
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

    context '#parseable' do
      specify '#parseable 1' do
        result.name = 'Aus bus cf. bus Smith and Jones, 1920'
        result.parse
        expect(result.parseable).to eq(false)
      end 

      specify '#parseable 2' do
        result.name = 'asdfasdfasf'
        result.parse
        expect(result.parseable).to eq(false)
      end 

      specify '#parseable 3' do
        result.name = 'valerius (Eades, 1964)'
        result.parse
        expect(result.parseable).to eq(false)
      end 
    end

    context '#genus' do
      specify 'as uninomial' do
        result.name = 'Bus'
        result.parse
        expect(result.genus).to eq('Bus')
      end

      specify 'as binomial' do
        result.name = 'Bus aus'
        result.parse
        expect(result.genus).to eq('Bus')
      end
    end

    context 'parsing' do
      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:genus1) { Protonym.create(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus) ) }
      let!(:species1) { Protonym.create(name: 'bus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species) ) }

      before do
        result.project_id = 1
      end

      context 'author and year' do
        specify '#author exception 1' do
          result.name = 'TyphlocybaFicocyba icaria'
          result.parse
          expect(result.author).to eq(nil)
        end

        specify '#author exception 2' do
          result.name = '(Zygina)%20nivea'
          result.parse
          expect(result.author).to eq(nil)
        end

        specify '#author for genus' do
          result.name = 'Aus Smith and Jones, 1920'
          result.parse
          result.build_result
          expect(result.author).to eq('Smith & Jones')
        end

        specify '#author for subgenus' do
          result.name = 'Aus (Bus) Smith and Jones, 1920'
          result.parse
          result.build_result
          expect(result.author).to eq('Smith & Jones')
        end

        specify '#author for species' do
          result.name = 'Aus bus Smith and Jones, 1920'
          result.parse
          result.build_result
          expect(result.author).to eq('Smith & Jones')
        end

        specify '#author for subspecies' do
          result.name = 'Aus bus cus dus Smith, 1920'
          result.parse
          result.build_result
          expect(result.author).to eq('Smith')
        end

        specify '#year for genus' do
          result.name = 'Aus Smith and Jones, 1920'
          result.parse
          result.build_result
          expect(result.year).to eq('1920')
        end

        specify '#year for subgenus' do
          result.name = 'Aus (Bus) Smith and Jones'
          result.parse
          result.build_result
          expect(result.year).to eq(nil)
        end

        specify '#year for species' do
          result.name = 'Aus bus Smith and Jones, 1920'
          result.parse
          result.build_result
          expect(result.year).to eq('1920')
        end

        specify '#year for subspecies' do
          result.name = 'Aus bus cus dus Smith, 1920'
          result.parse
          result.build_result
          expect(result.year).to eq('1920')
        end
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

        specify '#combination_exists? 2' do
          a = Combination.create!(genus: genus1, species: species1)
          expect(result.combination_exists?).to eq(a)
        end
      end

      context '#other_matches' do
        let!(:genus2) { Protonym.create!(name: 'Zus', parent: genus1, rank_class: Ranks.lookup(:iczn, :subgenus)) }
        let!(:c) { Combination.create!(genus: genus1,  species: species1, verbatim_name: 'Aus buss') }

        specify '#other_matches :subgenus' do
          result.name = 'Zus'
          result.parse
          expect(result.other_matches[:subgenus]).to include(genus2)
        end

        specify '#other_matches :verbatim' do
          result.name = 'Aus buss Smith and Jones, 1920'
          result.parse
          expect(result.other_matches[:verbatim]).to include(c)
        end

        specify '#other_matches :original_combination' do
          species1.original_genus = genus2
          species1.save!
          result.name = 'Zus bus'
          result.parse
          expect(result.other_matches[:original_combination]).to include(species1)
        end
      end

      context 'matches' do
        context 'unambiguous' do
          before do
            result.name = 'Aus bus Smith and Jones, 1920'
            result.parse
            result.build_result
          end

          let(:combination) { result.combination }

          specify '#name_count' do
            expect(result.name_count).to eq(2)
          end

          specify '#genus' do
            expect(result.genus).to eq('Aus') 
          end

          specify '#protonym_result' do
            expect(result.protonym_result[:genus]).to include(genus1)
          end

          specify '#preparse' do
            expect(result.preparse).to contain_exactly(result.name)
          end

          specify '#author_word_position' do
            expect(result.author_word_position).to eq(8)
          end

          specify '#name_without_author_year' do
            expect(result.name_without_author_year).to eq('Aus bus')
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

        context 'infraspecifics' do
          specify '#string 1' do
            result.name = 'Aus bus form cus Smith and Jones, 1920'
            result.parse
            expect(result.string('form')).to eq('cus') 
          end

          specify '#string 2' do
            result.name = 'Aus bus var. cus Smith and Jones, 1920'
            result.parse
            expect(result.string('variety')).to eq('cus') 
          end

          specify '#string 3' do
            result.name = 'Aus bus cus var. dus Smith and Jones, 1920'
            result.parse
            expect(result.string('subspecies')).to eq('cus') 
          end

          specify '#string 4' do
            result.name = 'Aus cf bus'
            result.parse
            expect(result.genus).to eq('Aus')
            expect(result.species).to eq('bus')
          end

          # Not yet handled in Biodiversity
          # specify '#string 5' do
          #  result.name = 'Aus bus cf dus'
          #  result.parse
          #  expect(result.genus).to eq('Aus')
          #  expect(result.species).to eq('bus')
          #  expect(result.subspecies).to eq('dus')
          # end

          specify '#build_result succeeds' do
            result.name = 'Aus bus form cus Smith and Jones, 1920'
            result.parse
            expect(result.build_result).to be_truthy
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

          specify '#ambiguous_ranks' do
            expect(result.ambiguous_ranks).to contain_exactly(:species)
          end

          specify '#disambiguate_combination' do
            c = result.disambiguate_combination( { species: species2.id } )
            expect(c.genus).to eq(genus1)
            expect(c.species).to eq(species2)
          end

          specify '#disambiguated_combination' do
            c = result.disambiguate_combination( { species: species2.id } )
            expect(result.disambiguated_combination).to eq(c)
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
              species: {
                genus: "Aus",
                species: "bus",
                authorship: {
                  verbatim: "Smith and Jones, 1920",
                  normalized: "Smith & Jones 1920",
                  year: "1920",
                  authors: ["Smith", "Jones"],
                  originalAuth: {
                    authors: ["Smith", "Jones"],
                    year: {
                      year: "1920"
                    }
                  }
                }
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

        specify '#combination 1' do
          c = result.combination
          expect(c.genus_id).to eq(subgenus.id)
        end

        specify '#combination 2' do
          c = result.combination
          expect(c.subgenus_id).to eq(subgenus.id)
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

        specify '#name_count' do
          expect(result.name_count).to eq(4)
        end

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
