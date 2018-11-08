require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let!(:root) { FactoryBot.create(:root_taxon_name) }
  let!(:genus) { Protonym.create!(name: 'Erythroneura', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let!(:subspecies) { Protonym.create!(name: 'vitata', parent: genus, rank_class: Ranks.lookup(:iczn, :subspecies)) }
  let(:species) { FactoryBot.create(:iczn_species, parent: genus) }

  context 'asserting gender with a TaxonNameClassification' do
    before {
      genus.update_attributes(taxon_name_classifications_attributes: [{type: 'TaxonNameClassification::Latinized::Gender::Masculine' }])  
    }

    specify '#gender_instance' do
      expect(genus.gender_instance).to eq(genus.taxon_name_classifications.first)
    end

    specify '#gender_class' do
      expect(genus.gender_class).to eq(TaxonNameClassification::Latinized::Gender::Masculine)
    end

    specify '#gender_name' do
      expect(genus.gender_name).to eq('masculine')
    end
  end

  context 'modifying gender' do
    let!(:gender) { FactoryBot.create(
      :taxon_name_classification, 
      taxon_name: genus, type: 'TaxonNameClassification::Latinized::Gender::Masculine') }

    specify 'with no attributes' do
      expect(species.get_full_name_html).to eq('<i>Erythroneura vitis</i>')
    end

    context 'with gender attributes set' do
      before do 
        species.update_attributes(
          masculine_name: 'vitus',
          feminine_name: 'vita',
          neuter_name: 'vitum'
        )
      end 

      specify 'name is valid' do
        expect(species.valid?).to be_truthy
      end

      context 'ending changes with TaxonNameClassification' do
        specify 'when classified as masculine' do
          expect(species.get_full_name_html).to eq('<i>Erythroneura vitus</i>')
        end 

        specify 'when classified as feminine' do
          gender.update_attribute(:type, 'TaxonNameClassification::Latinized::Gender::Feminine')
          expect(species.get_full_name_html).to eq('<i>Erythroneura vita</i>')
        end

        specify 'when classified as neuter' do
          gender.update_attribute(:type, 'TaxonNameClassification::Latinized::Gender::Neuter')
          expect(species.get_full_name_html).to eq('<i>Erythroneura vitum</i>')
        end
      end
    end
  end

end
