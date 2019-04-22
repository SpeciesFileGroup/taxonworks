require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  # TODO: ensure not needed
  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonName.delete_all
    Citation.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:protonym) { Protonym.new }
  let!(:root) { Protonym.create!(name: 'Root', rank_class: 'NomenclaturalRank')  }

  let(:order) { Protonym.create!(name: 'Hymenoptera', parent: root, rank_class: Ranks.lookup(:iczn, :order ) ) } 
  let(:family) { Protonym.create!(name: 'Aidae', parent: order, rank_class: Ranks.lookup(:iczn, :family ) )  }
  let(:genus) { Protonym.create!(name: 'Aus', parent: family, rank_class: Ranks.lookup(:iczn, :genus ) )  }

  let(:alternate_genus) { Protonym.create!(name: 'Bus', parent: family, rank_class: Ranks.lookup(:iczn, :genus ) )  }

  let(:species) { Protonym.create!(name: 'aus', parent: genus, rank_class: Ranks.lookup(:iczn, :species ) )  } 

  let(:species_type_of_genus) { 
    FactoryBot.create(:taxon_name_relationship,
                      subject_taxon_name: species,
                      object_taxon_name: genus,
                      type: 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy')
  }

  let(:genus_type_of_family) { 
    FactoryBot.create(:taxon_name_relationship,
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
  end

  context 'with no original_combination relationships' do

    specify '#cached_original_combination is nil' do
      expect(species.cached_original_combination).to eq(nil)
    end 

    specify '#cached_original_combination_html is nil' do
      expect(species.cached_original_combination).to eq(nil)
    end 

  end

  context 'cached fields with verbatim_name set' do
    before {  species.update(verbatim_name: 'albo-nigra', original_genus: alternate_genus) }

    specify '#cached_original_combination' do
      expect(species.cached_original_combination).to eq('Bus albo-nigra')
    end

    specify '#cached_original_combination_html' do
      expect(species.cached_original_combination_html).to eq('<i>Bus albo-nigra</i>')
    end
  end

  context '#cached_original_combination is updated when' do
    before {
      species.original_genus = alternate_genus
    }

    specify 'rebuild method is called on save' do
      expect(species).to receive(:set_cached_original_combination)
      species.save
    end

    specify '#original_combination_relationships maps object to related' do
      expect(species.original_combination_relationships.reload.first.object_taxon_name).to eq(species) 
    end

    specify 'rebuild method is called on destroy' do
      expect(species.original_genus_relationship).to receive(:set_cached_original_combination)
      species.original_genus_relationship.destroy
    end

    specify 'genus relationship is created' do
      species.save
      expect(species.cached_original_combination).to eq('Bus aus')
    end

    specify 'genus relationship is destroyed' do
      species.save
      species.original_genus_relationship.destroy!
      species.reload
      expect(species.cached_original_combination).to eq(nil)
    end
  end

  specify '#original_genus set' do
    species.update(original_genus: genus)
    expect(species.cached_original_combination).to eq('Aus aus')
  end

  specify '#original_genus, #original_subgenus set' do
    species.update(original_genus: genus, original_subgenus: genus)
    expect(species.cached_original_combination).to eq('Aus (Aus) aus')
  end

  specify '#original_genus, #original_subgenus, #original_species set' do
    species.update(original_genus: genus, original_subgenus: genus, original_species: species)
    expect(species.cached_original_combination).to eq('Aus (Aus) aus')
  end

  specify '#original_genus, #original_subgenus, #original_species, #original_subspecies set' do
    species.update(original_genus: genus, original_subgenus: genus, original_species: species, original_subspecies: species)
    expect(species.cached_original_combination).to eq('Aus (Aus) aus aus')
  end

  specify '#original_genus, #original_subgenus, #original_species, #original_subspecies, #original_variety set' do
    species.update(original_genus: genus, original_subgenus: genus, original_species: species, original_subspecies: species, original_variety: species)
    expect(species.cached_original_combination).to eq('Aus (Aus) aus aus var. aus')
  end

  specify '#original_genus, #original_subgenus, #original_species, #original_subspecies, #original_variety set' do
    species.update(original_genus: genus, original_subgenus: genus, original_species: species, original_subspecies: species, original_variety: species)
    expect(species.cached_original_combination_html).to eq('<i>Aus</i> (<i>Aus</i>) <i>aus aus</i> var. <i>aus</i>')
  end

  specify 'subgenus original combination' do
    alternate_genus.update(parent: genus, rank_class: Ranks.lookup(:iczn, :subgenus), original_genus: alternate_genus)
    expect(alternate_genus.cached_original_combination).to eq('Bus') 
  end

  specify 'incomplete relationship: missing original species' do
    species.update(original_genus: genus, original_subspecies: species)
    expect(species.cached_original_combination).to eq('Aus [SPECIES NOT SPECIFIED] aus')
  end

  specify 'incomplete relationship: missing original genus 1' do
    species.update(original_genus: nil, original_subgenus: genus)
    expect(species.cached_original_combination).to eq('[GENUS NOT SPECIFIED] (Aus) aus')
  end

  specify 'incomplete relationship: missing original genus 2' do
    species.update(original_genus: nil, original_subgenus: genus)
    expect(species.cached_original_combination_html).to eq('[GENUS NOT SPECIFIED] (<i>Aus</i>) <i>aus</i>')
  end

  specify 'misspelled original combination 1' do
    alternate_genus.update(iczn_set_as_misspelling_of: genus, original_genus: alternate_genus)
    expect(alternate_genus.cached_original_combination).to eq('Bus [sic]')
  end

  specify 'misspelled original combination 2' do
    alternate_genus.update(iczn_set_as_misspelling_of: genus, original_genus: alternate_genus)
    expect(alternate_genus.cached_original_combination_html).to eq('<i>Bus</i> [sic]')
  end

  specify 'misspelled original combination 3' do
    alternate_genus.update(iczn_set_as_misspelling_of: genus, original_genus: alternate_genus)
    species.update(original_genus: alternate_genus)
    expect(species.cached_original_combination_html).to eq('<i>Bus</i> [sic] <i>aus</i>')
  end


end
