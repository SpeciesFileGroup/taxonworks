require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:taxon_name) { TaxonName.new }

  context 'using before :all' do
    before(:all) do
      @subspecies = FactoryGirl.create(:iczn_subspecies)
      @species    = @subspecies.ancestor_at_rank('species')
      @subgenus   = @subspecies.ancestor_at_rank('subgenus')
      @genus      = @subspecies.ancestor_at_rank('genus')
      @tribe      = @subspecies.ancestor_at_rank('tribe')
      @family     = @subspecies.ancestor_at_rank('family')
      @root       = @subspecies.root
    end

    after(:all) do
      TaxonNameRelationship.delete_all
      TaxonName.delete_all 
      TaxonNameHierarchy.delete_all
      # TODO: find out why this exists and resolve - presently leaving sources in the models
      Citation.delete_all
      Source.destroy_all
    end

    context 'no_cached' do
      let(:n) {Protonym.create(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: @root, no_cached: true) }

      specify 'when true cached is set to NO_CACHE_MESSAGE' do
        expect(n.cached).to eq(TaxonName::NO_CACHED_MESSAGE)
      end

      specify 'when true cached_author_year is set to NO_CACHE_MESSAGE' do
        expect(n.cached_author_year).to eq(TaxonName::NO_CACHED_MESSAGE)
      end

      specify 'when true cached_classified_as is set to NO_CACHE_MESSAGE' do
        expect(n.cached_classified_as).to eq(TaxonName::NO_CACHED_MESSAGE)
      end

      specify 'when true cached_html is set to NO_CACHE_MESSAGE' do
        expect(n.cached_html).to eq(TaxonName::NO_CACHED_MESSAGE)
      end

      # Deprecated
      # specify 'when true cached_higher_classification is set to NO_CACHE_MESSAGE' do
      #   expect(n.cached_higher_classification).to eq(TaxonName::NO_CACHED_MESSAGE)
      # end
    end

    context 'after save' do
      context 'create_new_combination_if_absent' do
        specify 'new combination' do
          expect(TaxonName.with_cached_html('<i>Erythroneura vitis</i>').count).to eq(0)
          sp = FactoryGirl.build(:relationship_species)
          sp.save
          expect(sp.cached_html).to eq('<i>Erythroneura vitis</i>')
          expect(TaxonName.with_cached_html('<i>Erythroneura vitis</i>').count).to eq(1)
          sp.save
          expect(TaxonName.with_cached_html('<i>Erythroneura vitis</i>').count).to eq(1)
        end
      end

      context 'set_cached_names_for_dependants' do
        specify 'dependants' do
          family = FactoryGirl.create(:relationship_family)
          genus1 = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: family)
          genus2 = FactoryGirl.create(:relationship_genus, name: 'Bus', parent: family)
          species = FactoryGirl.create(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758)
          species.original_genus = genus2
          species.source_classified_as = family
          species.save
          species.reload

          t = species.created_at
          expect(species.cached).to eq('Aus aus')
          expect(species.cached_html).to eq('<i>Aus aus</i>')
          expect(species.cached_original_combination).to eq('<i>Bus aus</i>')
          expect(species.cached_author_year).to eq('(Linnaeus, 1758)')
          expect(species.cached_classified_as).to eq(' (as Erythroneuridae)')
          genus1.name = 'Cus'
          genus1.save
          species.reload
          expect(species.cached).to eq('Cus aus')
          expect(species.cached_html).to eq('<i>Cus aus</i>')
          expect(species.cached_original_combination).to eq('<i>Bus aus</i>')
          genus2.name = 'Dus'
          genus2.save
          species.reload
          expect(species.cached).to eq('Cus aus')
          expect(species.cached_html).to eq('<i>Cus aus</i>')
          expect(species.cached_original_combination).to eq('<i>Dus aus</i>')
          family.name = 'Cicadellidae'
          family.save
          species.reload
          expect(species.cached_classified_as).to eq(' (as Cicadellidae)')
          expect(species.created_at).to eq(t)
        end

        specify 'genus with gender change' do
          family = FactoryGirl.create(:relationship_family)
          genus1 = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: family)
          genus2 = FactoryGirl.create(:relationship_genus, name: 'Ba', parent: family)
          c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
          c2 = FactoryGirl.create(:taxon_name_classification, taxon_name: genus2, type: 'TaxonNameClassification::Latinized::Gender::Feminine')
          genus1.reload
          genus2.reload
          species = FactoryGirl.build(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758, masculine_name: 'aus', feminine_name: 'aa', neuter_name: 'aum')
          species.save
          expect(species.cached_html).to eq('<i>Aus aus</i>')
          expect(species.cached).to eq('Aus aus')
          species.parent = genus2
          species.save
          species.reload
          expect(species.cached_html).to eq('<i>Ba aa</i>')
          expect(species.cached).to eq('Ba aa')
        end
     
        specify 'gender of genus change change' do
          family = FactoryGirl.create(:relationship_family)
          genus1 = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: family)
          c1 = FactoryGirl.create(:taxon_name_classification, taxon_name: genus1, type: 'TaxonNameClassification::Latinized::Gender::Masculine')
          genus1.reload
          species = FactoryGirl.build(:relationship_species, name: 'aus', parent: genus1, verbatim_author: 'Linnaeus', year_of_publication: 1758, masculine_name: 'aus', feminine_name: 'aa', neuter_name: 'aum')
          species.save
          expect(species.cached_html).to eq('<i>Aus aus</i>')
          expect(species.cached).to eq('Aus aus')
          c1.type = 'TaxonNameClassification::Latinized::Gender::Feminine'
          c1.save
          genus1.reload
          species.reload
          species.save
          species.reload
          expect(species.cached_html).to eq('<i>Aus aa</i>')
          expect(species.cached).to eq('Aus aa')
        end

        specify 'nomimotypical subgenus original combination' do
          genus1 = FactoryGirl.create(:relationship_genus, name: 'Aus')
          subgenus1 = FactoryGirl.create(:iczn_subgenus, name: 'Bus', parent: genus1)
          #r = TaxonNameRelationship::OriginalCombination::OriginalGenus.create(subject_taxon_name: genus1, object_taxon_name: genus1)
          genus1.original_genus = genus1
          genus1.save
          genus1.reload
          expect(genus1.cached_original_combination).to eq('<i>Aus</i>')
          expect(genus1.cached_primary_homonym).to eq('Aus')

          subgenus1.soft_validate(:single_sub_taxon)
          subgenus1.fix_soft_validations
          genus1.soft_validate(:single_sub_taxon)
          genus1.fix_soft_validations
          #r.soft_validate(:single_sub_taxon)
          #r.fix_soft_validations
          genus1.reload
          expect(genus1.cached_original_combination).to eq('<i>Aus</i>')
          expect(genus1.cached_primary_homonym).to eq('Aus')
          subgenus2 = genus1.lowest_rank_coordinated_taxon
          expect(subgenus2.name).to eq('Aus')
          expect(subgenus2.rank_name).to eq('subgenus')
          expect(subgenus2.get_original_combination).to eq('<i>Aus</i>')
        end
      
      end
    end
  end
end
