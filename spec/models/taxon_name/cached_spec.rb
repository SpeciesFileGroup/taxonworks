require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:root) { FactoryBot.create(:root_taxon_name) }

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all 
    TaxonNameHierarchy.delete_all
    # TODO: find out why this exists and resolve - presently leaving sources in the models
    Citation.delete_all
    Source.destroy_all
  end

  context 'quick test' do
    let(:genus) { Protonym.create(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
    let(:original_genus) { Protonym.create(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
    let!(:species) { Protonym.create!(
      name: 'vulnerata',
      rank_class: Ranks.lookup(:iczn, 'species'),
      parent: genus,
      original_genus: original_genus,
      verbatim_author: 'Fitch & Say',
      year_of_publication: 1800) }

    specify '#not_specified 1' do
      species.update!(parent: root, original_genus: nil)

      # !! At this point species.cached == "</i>[<i></i>GENUS NOT SPECIFIED<i></i>]<i> vulnerata". See #2236

      expect(species.reload.cached).to eq('[GENUS NOT SPECIFIED] vulnerata')
    end
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
      context 'everything empty' do
        specify 'nothing there' do
          expect(TaxonName.where(cached_html: '<i>Erythroneura vitis</i>').count).to eq(0)
        end
      end

      let(:family) { FactoryBot.create(:relationship_family) }
      let(:genus1) { FactoryBot.create(:relationship_genus, name: 'Aus', parent: family) }
      let(:genus2) { FactoryBot.create(:relationship_genus, name: 'Bus', parent: family) }
      let(:species) { FactoryBot.create(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758) }
      let(:subspecies) { Protonym.create(name: 'aus', rank_class: Ranks.lookup(:iczn, :subspecies), parent: species) }
      let(:t) {species.created_at}

      specify '#not binomial' do
        genus1.taxon_name_classifications.create!(type: 'TaxonNameClassification::Iczn::Unavailable::NonBinomial')
        species.taxon_name_classifications.create!(type: 'TaxonNameClassification::Iczn::Unavailable::NonBinomial')
        species.update( original_species: species)
        genus1.update( original_genus: genus1)
        expect(species.cached_original_combination).to eq('aus')
        expect(species.cached).to eq('Aus aus')
        expect(genus1.cached_original_combination).to eq('Aus')
        expect(genus1.cached).to eq('Aus')
      end

      context '#cached for subspecies with gender change' do
        before do
          genus1.taxon_name_classifications.create!(type: 'TaxonNameClassification::Latinized::Gender::Feminine')
          species.taxon_name_classifications.create!(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
          subspecies.taxon_name_classifications.create!(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')

          species.update(
            masculine_name: 'aus',
            feminine_name: 'aa',
            neuter_name: 'aum',
            verbatim_name: 'aum'
          )

          subspecies.update(
            name: 'bus',
            masculine_name: 'bus',
            feminine_name: 'ba',
            neuter_name: 'bum',
            original_genus: genus1,
            original_species: species,
            original_subspecies: subspecies
          )
        end
        
        specify '#cached' do
          subspecies.save
          expect(subspecies.cached_original_combination).to eq('Aus aa bus')
          expect(subspecies.cached).to eq('Aus aa ba')
        end
      end

      context 'original combination referencing two subpecies' do
        let(:subspecies2) { Protonym.create(name: 'gus', rank_class: Ranks.lookup(:iczn, :subspecies), parent: species) }
        before do
          subspecies.update(
            name: 'zus',
            original_genus: genus1, 
            original_species: subspecies2,
            original_form: subspecies,
          )
        end
       
        specify '#cached_original_combiantion' do
          expect(subspecies.cached_original_combination).to eq('Aus gus f. zus')
        end
      end

      specify '#cached for subspecies' do
        genus2.update(parent: genus1, rank_class: Ranks.lookup(:iczn, :subgenus))
        species.update(parent: genus2)
        expect(subspecies.cached_html).to eq('<i>Aus</i> (<i>Bus</i>) <i>aus aus</i>')
      end

      context 'Candidatus' do
        let(:icnp_genus) { Protonym.create(name: 'Aus', rank_class: Ranks.lookup(:icnp, :genus), parent: root) }
        let(:icnp_species) { Protonym.create(name: 'bus', rank_class: Ranks.lookup(:icnp, :species), parent: icnp_genus) }

        before { TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate::Candidatus.create!(taxon_name: icnp_species) }

        specify '#cached_html' do
          expect(icnp_species.cached_html).to eq('"<i>Candidatus</i> Aus bus"')
        end

        specify 'cached' do
          expect(icnp_species.cached).to eq('Aus bus')
        end
      end

      context 'hybrid' do
        let(:hybrid_genus) { Protonym.create(name: 'Aus', rank_class: Ranks.lookup(:icn, :genus), parent: root) }
        let(:hybrid_species) { Protonym.create(name: 'aaa', rank_class: Ranks.lookup(:icn, :species), parent: hybrid_genus) }

        before { TaxonNameClassification::Icn::Hybrid.create!(taxon_name: hybrid_species) } 

        specify '#cached_html' do
          expect(hybrid_species.cached_html).to eq('<i>Aus</i> ×<i>aaa</i>')
        end

        specify '#cached' do
          expect(hybrid_species.cached).to eq('Aus aaa')
        end
      end

      context 'basic use' do
        let!(:sp) { FactoryBot.create(:relationship_species) }

        specify '#cached_html' do
          expect(sp.cached_html).to eq('<i>Erythroneura vitis</i>')
        end

        specify 'can be found' do
          expect(TaxonName.where(cached_html: '<i>Erythroneura vitis</i>').count).to eq(1)
        end
      end

      context 'fossil' do
        specify '#cached_html' do
          TaxonNameClassification::Iczn::Fossil.create!(taxon_name: species)
          expect(species.cached_html).to eq('† <i>Aus aus</i>')
        end
      end

      context 'above genus group' do
        specify '#cached' do
          expect(family.cached).to eq(family.name)
        end
      
        specify '#cached_html' do
          expect(family.cached_html).to eq(family.name)
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
            species.update(original_genus: genus2, source_classified_as: family)
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

          specify '#cached_original_combination_html' do 
            expect(species.cached_original_combination_html).to eq('<i>Bus aus</i>')
          end

          specify '#cached_original_combination' do 
            expect(species.cached_original_combination).to eq('Bus aus')
          end

          context 'changing the genus (parent) name' do
            before do 
              genus1.update(name: 'Cus') 
              species.reload
            end 

            specify '#cached 1' do
              expect(genus1.cached).to eq('Cus')
            end

            specify '#cached 1' do
              expect(species.cached).to eq('Cus aus')
            end

            specify '#cached_html' do
              expect(species.cached_html).to eq('<i>Cus aus</i>')
            end

            specify '#not_binomial' do
              expect(species.not_binomial?).to be_falsey
              species.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Unavailable::NonBinomial')
              expect(species.not_binomial?).to be_truthy
              species.reload
              species.save
              expect(species.cached_html).to eq('<i>Cus aus</i>')
            end

            specify '#cached_original_combination is not changed' do
              expect(species.cached_original_combination_html).to eq('<i>Bus aus</i>')
            end

            specify '#cached_original_combination is not changed' do
              expect(species.cached_original_combination).to eq('Bus aus')
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

            specify '#cached_original_combination_html' do
              expect(species.cached_original_combination_html).to eq('<i>Dus aus</i>')
            end

            specify '#cached_original_combination' do
              expect(species.cached_original_combination).to eq('Dus aus')
            end
          end

          context 'changing classified as' do
            before do 
              family.update(name: 'Cicadellidae' ) 
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
          let(:genus3) { FactoryBot.create(:relationship_genus, name: 'Ba', parent: family) }

          context 'species names, genus with gender change' do
            let(:species) {
              FactoryBot.create(:relationship_species, 
                                 name: 'aus', 
                                 parent: genus1, 
                                 verbatim_author: 'Linnaeus', 
                                 year_of_publication: 1758, 
                                 masculine_name: 'aus', 
                                 feminine_name: 'aa', 
                                 neuter_name: 'aum')
            }

            before do 
              c1 = FactoryBot.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
              c2 = FactoryBot.create(:taxon_name_classification, taxon_name: genus3, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
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
            let!(:c1) { FactoryBot.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Latinized::Gender::Masculine')}
            let!(:species) { FactoryBot.create(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758, masculine_name: 'aus', feminine_name: 'aa', neuter_name: 'aum')} 

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

          context 'not binomial cached' do
            let!(:c1) { FactoryBot.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Iczn::Unavailable::NonBinomial')}
            let!(:species) { FactoryBot.create(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758)}
            let!(:c2) { FactoryBot.create(:taxon_name_classification, taxon_name: species, type: 'TaxonNameClassification::Iczn::Unavailable::NonBinomial')}

            specify 'not binomial genus' do
              genus1.save!
              species.save!
              expect(genus1.cached).to eq('Aus')
              expect(species.cached).to eq('Aus aus')
            end
          end

          context 'combination of a synonym' do
            let!(:species) { FactoryBot.create(:relationship_species, name: 'aus', parent: genus1)}
            let!(:species_syn) { FactoryBot.create(:relationship_species, name: 'bus', parent: genus1)}
            let!(:combination) {Combination.create(genus: genus1, species: species_syn) }
            let!( :r1) { FactoryBot.create(:taxon_name_relationship, subject_taxon_name: species_syn, object_taxon_name: species, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym' )}
            specify 'combination cached_valid_taxon_name_id' do
              combination.reload
              expect(combination.cached_valid_taxon_name_id).to eq(species.id)
              r2 = FactoryBot.create(:taxon_name_relationship, subject_taxon_name: species, object_taxon_name: species_syn, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym' )
              r1.destroy
              species.reload
              combination.reload
              expect(species.cached_valid_taxon_name_id).to eq(species_syn.id)
              expect(combination.cached_valid_taxon_name_id).to eq(species_syn.id)
            end
          end

          context 'two synonym relationships' do
            let!(:species1) { FactoryBot.create(:relationship_species, name: 'aus', parent: genus1)}
            let!(:species2) { FactoryBot.create(:relationship_species, name: 'bus', parent: genus1)}
            let!(:species_syn) { FactoryBot.create(:relationship_species, name: 'cus', parent: genus1)}
            let!( :r1) { FactoryBot.create(:taxon_name_relationship, subject_taxon_name: species_syn, object_taxon_name: species1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym' )}
            let!( :r2) { FactoryBot.create(:taxon_name_relationship, subject_taxon_name: species_syn, object_taxon_name: species2, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym' )}
            let!(:source1) { FactoryBot.create(:soft_valid_bibtex_source_article, year: 1999) }
            let!(:source2) { FactoryBot.create(:soft_valid_bibtex_source_article, year: 2000) }

            specify 'valid species with one citation' do
              r1.citations.create(source: source1)
              species_syn.reload
              expect(species_syn.cached_valid_taxon_name_id).to eq (species1.id)
            end

            specify 'valid species with two citation' do
              r1.citations.create(source: source1)
              r2.citations.create(source: source2)
              species_syn.reload
              expect(species_syn.cached_valid_taxon_name_id).to eq (species2.id)
            end
          end

        end
      end
    end
  end
end
