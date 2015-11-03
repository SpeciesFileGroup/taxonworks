require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    Source.delete_all
  end

  let(:protonym) { Protonym.new }
  let!(:root) { Protonym.create!(name: 'Root', rank_class: NomenclaturalRank)  }

  let(:order) { Protonym.create!(name: 'Hymenoptera', parent: root, rank_class: Ranks.lookup(:iczn, :order ) ) } 
  let(:family) { Protonym.create!(name: 'Aidae', parent: order, rank_class: Ranks.lookup(:iczn, :family ) )  }
  let(:genus) { Protonym.create!(name: 'Aus', parent: family, rank_class: Ranks.lookup(:iczn, :genus ) )  }

  let(:alternate_genus) { Protonym.create!(name: 'Bus', parent: family, rank_class: Ranks.lookup(:iczn, :genus ) )  }

  let(:species) { Protonym.create!(name: 'aus', parent: genus, rank_class: Ranks.lookup(:iczn, :species ) )  } 

  let(:species_type_of_genus) { 
    FactoryGirl.create(:taxon_name_relationship,
                       subject_taxon_name: species,
                       object_taxon_name: genus,
                       type: 'TaxonNameRelationship::Typification::Genus::Monotypy::Original')
  }

  let(:genus_type_of_family) { 
    FactoryGirl.create(:taxon_name_relationship,
                       subject_taxon_name: genus,
                       object_taxon_name: family,
                       type: 'TaxonNameRelationship::Typification::Family')
  }

  context 'associations' do
    context 'has_many' do
      specify 'original_combination_relationships' do 
        expect(protonym).to respond_to(:original_combination_relationships)
      end
    end

    context 'has_one' do
      specify 'original_combination_source' do
        expect(protonym).to respond_to(:original_combination_source)
      end
    end

    context 'cached_original_combination is updated when' do
      before {
        species.original_genus = alternate_genus
      }

      specify 'rebuild method is called on save' do
        expect(species).to receive(:set_cached_original_combination)
        species.save
      end

      specify 'rebuild method is called on destroy' do
        expect(species.original_genus_relationship).to receive(:set_cached_original_combination)
        species.original_genus_relationship.destroy
      end

      specify 'genus relationship is created' do
        species.save
        expect(species.cached_original_combination).to eq('<i>Bus aus</i>')
      end

      specify 'genus relationship is destroyed' do
        species.save
        species.original_genus_relationship.destroy!
        species.reload
        expect(species.cached_original_combination).to eq(nil)
      end
    end

    context 'example usage' do
    end
  end # end associations
end
