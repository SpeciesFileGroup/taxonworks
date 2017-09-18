require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:root) {
    subspecies = FactoryGirl.create(:iczn_subspecies)
    subspecies.root
  }

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all 
    TaxonNameHierarchy.delete_all
    # TODO: find out why this exists and resolve - presently leaving sources in the models
    Citation.delete_all
    Source.destroy_all
  end

  context 'when #no_cached = true then NO_CACHED_MESSAGE is used with' do
    let(:n) {Protonym.create(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: root, no_cached: true) }

    specify '#cached' do
      expect(n.cached).to eq(TaxonName::NO_CACHED_MESSAGE)
    end

    specify '#cached_author_year' do
      expect(n.cached_author_year).to eq(TaxonName::NO_CACHED_MESSAGE)
    end

    specify '#cached_classified_as' do
      expect(n.cached_classified_as).to eq(TaxonName::NO_CACHED_MESSAGE)
    end

    specify '#cached_html' do
      expect(n.cached_html).to eq(TaxonName::NO_CACHED_MESSAGE)
    end
  end

  context 'after save' do

    context 'clean slate' do
      context 'clean slate' do
        specify 'nothing there' do
          expect(TaxonName.with_cached_html('<i>Erythroneura vitis</i>').count).to eq(0)
        end
      end

      let(:family) { FactoryGirl.create(:relationship_family) }
      let(:genus1) { FactoryGirl.create(:relationship_genus, name: 'Aus', parent: family) }
      let(:genus2) { FactoryGirl.create(:relationship_genus, name: 'Bus', parent: family) }
      let(:species) { FactoryGirl.create(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758) }
      let(:t) {species.created_at}

      context 'basic use' do
        let!(:sp) { FactoryGirl.create(:relationship_species) }

        specify 'sets cached_html' do
          expect(sp.cached_html).to eq('<i>Erythroneura vitis</i>')
        end

        specify 'can be found' do
          expect(TaxonName.with_cached_html('<i>Erythroneura vitis</i>').count).to eq(1)
        end
      end

      context '#combination_verbatim_name' do
        let(:c) {Combination.create(genus: genus1, species: species, verbatim_name: 'Aa aa')}

        specify 'over-rides #cached when provided' do
          expect(c.cached).to eq('Aa aa')
        end 

      end

      context '#set_cached_names_for_dependants_and_self' do
        
        context 'species methods' do
          before do 
            species.original_genus = genus2
            species.source_classified_as = family
            species.save
            species.reload
          end 

          specify '#cached' do
            expect(species.cached).to eq('Aus aus')
          end

          specify '#cached_author_year' do
            expect(species.cached_author_year).to eq('(Linnaeus, 1758)')
          end

          specify '#cached_classified_as' do
            expect(species.cached_classified_as).to eq(' (as Erythroneuridae)')
          end

          specify '#cached_html' do
            expect(species.cached_html).to eq('<i>Aus aus</i>')
          end

          specify '#cached_original_combination' do 
            expect(species.cached_original_combination).to eq('<i>Bus aus</i>')
          end

          context 'changing the genus (parent) name' do
            before do 
              genus1.name = 'Cus'
              genus1.save!
              species.reload
            end 

            specify '#cached' do
              expect(species.cached).to eq('Cus aus')
            end

            specify '#cached_html' do
              expect(species.cached_html).to eq('<i>Cus aus</i>')
            end

            specify '#cached_original_combination is not changed' do
              expect(species.cached_original_combination).to eq('<i>Bus aus</i>')
            end
          end

          context 'changing the genus from original combination' do
            before do
              genus2.name = 'Dus'
              genus2.save
              species.reload
            end 

            specify '#cached is not changed' do
              expect(species.cached).to eq('Aus aus')
            end

            specify '#cached_html is not changed' do
              expect(species.cached_html).to eq('<i>Aus aus</i>')
            end

            specify '#cached_original_combination' do
              expect(species.cached_original_combination).to eq('<i>Dus aus</i>')
            end
          end

          context 'changing classified as' do
            before do 
              family.name = 'Cicadellidae'
              family.save
              species.reload
            end 

            specify '#cached_classified_as' do
              expect(species.cached_classified_as).to eq(' (as Cicadellidae)')
            end

            specify '#created_at' do
              expect(species.created_at).to eq(t)
            end
          end
        end

        context 'with gender' do
          let(:genus3) { FactoryGirl.create(:relationship_genus, name: 'Ba', parent: family) }

          context 'species names, genus with gender change' do
            let(:species) {
              FactoryGirl.create(:relationship_species, 
                                 name: 'aus', 
                                 parent: genus1, 
                                 verbatim_author: 'Linnaeus', 
                                 year_of_publication: 1758, 
                                 masculine_name: 'aus', 
                                 feminine_name: 'aa', 
                                 neuter_name: 'aum')
            }

            before do 
              c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
              c2 = FactoryGirl.create(:taxon_name_classification, taxon_name: genus3, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
            end 

            specify 'case1 #cached_html' do
              expect(species.cached_html).to eq('<i>Aus aus</i>')
            end

            specify 'case1 #cached' do
              expect(species.cached).to eq('Aus aus')
            end

            context 'changing parent' do
              before do
                species.parent = genus3
                species.save
                species.reload
              end

              specify 'case2 #cached_html' do
                expect(species.cached_html).to eq('<i>Ba aa</i>')
              end

              specify 'case2 #cached' do
                expect(species.cached).to eq('Ba aa')
              end
            end
          end

          context 'species names vs. gender of genus change' do
            let!(:c1) { FactoryGirl.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Latinized::Gender::Masculine')}
            let!(:species) { FactoryGirl.create(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758, masculine_name: 'aus', feminine_name: 'aa', neuter_name: 'aum')} 

            context 'masculine' do
              specify '#cached_html' do
                expect(species.cached_html).to eq('<i>Aus aus</i>')
              end

              specify '#cached' do
                expect(species.cached).to eq('Aus aus')
              end
            end

            context 'feminine' do
              before do 
                # TODO: @proceps- This pattern doesn't seem to make sense- c1 is updated, but species is required to be saved 
                # The c1 save should trigger the species update?
                c1.type = 'TaxonNameClassification::Latinized::Gender::Feminine'
                c1.save

                species.save
                species.reload
              end

              specify '#cached_html' do
                expect(species.cached_html).to eq('<i>Aus aa</i>')
              end

              specify '#cached' do
                expect(species.cached).to eq('Aus aa')
              end
            end
          end
        end
      end
    end
  end
end
