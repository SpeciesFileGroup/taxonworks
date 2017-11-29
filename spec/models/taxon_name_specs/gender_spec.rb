require 'rails_helper'

Dir[Rails.root.to_s + '/app/models/taxon_name_classification/**/*.rb'].each {
  |file| require_dependency(file) 
}

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:taxon_name) { TaxonName.new }

  context 'using before :all' do
    before(:all) do
      @subspecies = FactoryBot.create(:iczn_subspecies)
     #  @species    = @subspecies.ancestor_at_rank('species')
     #  @subgenus   = @subspecies.ancestor_at_rank('subgenus')
      @genus      = @subspecies.ancestor_at_rank('genus')
    #   @tribe      = @subspecies.ancestor_at_rank('tribe')
    #   @family     = @subspecies.ancestor_at_rank('family')
    #   @root       = @subspecies.root
    end

    after(:all) do
      TaxonNameRelationship.delete_all
      TaxonName.delete_all 
      # TODO: find out why this exists and resolve - presently leaving sources in the models
      Citation.delete_all
      Source.destroy_all
      TaxonNameHierarchy.delete_all
    end

    context 'asserting gender with a TaxonNameClassification' do
      before {
        @genus.update_attributes(taxon_name_classifications_attributes: [{type: 'TaxonNameClassification::Latinized::Gender::Masculine' }])  
      }

      specify '#gender_instance' do
        expect(@genus.gender_instance).to eq(@genus.taxon_name_classifications.first)
      end

      specify '#gender_class' do
        expect(@genus.gender_class).to eq(TaxonNameClassification::Latinized::Gender::Masculine)
      end

      specify '#gender_name' do
        expect(@genus.gender_name).to eq('masculine')
      end
    end

    context 'modifying gender' do
      let(:s) { FactoryBot.create(:iczn_species, parent: @genus) }

      let!(:gender) { FactoryBot.create(:taxon_name_classification, taxon_name: @genus, type: 'TaxonNameClassification::Latinized::Gender::Masculine') }

      specify 'with no attributes' do
        expect(s.get_full_name_html).to eq('<i>Erythroneura vitis</i>')
      end

      context 'with gender attributes set' do
        before {
          s.masculine_name = 'vitus'
          s.feminine_name  = 'vita'
          s.neuter_name    = 'vitum'
          s.save
        }
        
        specify 'name is valid' do
          expect(s.valid?).to be_truthy
        end

        context 'ending changes with TaxonNameClassification' do
          specify 'when classified as masculine' do
            # gender # creates gender for the first time 
            expect(s.get_full_name_html).to eq('<i>Erythroneura vitus</i>')
          end 

          specify 'when classified as feminine' do
            gender.type = 'TaxonNameClassification::Latinized::Gender::Feminine'
            gender.save
            expect(s.get_full_name_html).to eq('<i>Erythroneura vita</i>')
          end

          specify 'when classified as neuter' do
            gender.type = 'TaxonNameClassification::Latinized::Gender::Neuter'
            gender.save
            expect(s.get_full_name_html).to eq('<i>Erythroneura vitum</i>')
          end
        end
      end

    end

  end
end
