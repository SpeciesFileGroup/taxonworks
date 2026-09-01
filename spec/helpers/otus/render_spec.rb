require 'rails_helper'

# TODO: add author year

describe OtusHelper, type: :helper do

  # Don't let! 
  let(:root) { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let(:valid_genus) { Protonym.create!(name: 'Bus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }

  let(:species) { Protonym.create!(name: 'bus', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }
  let(:valid_species) { Protonym.create!(name: 'dus', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }

  let(:combination_genus) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  # let(:combination_species) { Protonym.create!(name: 'aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let(:protonym_species) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }

  let(:family) { Protonym.create!(name: 'Familidae', parent: root, rank_class: Ranks.lookup(:iczn, :family)) }


  # "Functions"
  let(:synonymize_genus) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: genus, object_taxon_name: valid_genus) }
  let(:synonymize_species) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: species, object_taxon_name: valid_species) }

  context 'mixed Latin' do
    let(:combination) { Combination.create!(genus:) }

    context 'label' do
      specify 'Latin genus as Combination with non-Latin name' do
        o = Otu.create!(taxon_name: combination, name: 'sp1')
        expect(helper.label_for_otu(o)).to eq('Aus sp1') 
      end

      specify 'Latin genus as Protonym with non-Latin name' do
        o = Otu.create!(taxon_name: genus, name: 'sp1')
        expect(helper.label_for_otu(o)).to eq('Aus sp1') 
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_genus
        o = Otu.create!(taxon_name: genus, name: 'sp1')
        expect(helper.label_for_otu(o)).to eq('Aus sp1 now Bus sp1') 
      end
    end

    context 'tag' do
      specify 'Latin genus as Combination with non-Latin name' do
        o = Otu.create!(taxon_name: combination, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><i>Aus</i> <b>sp1</b></span>') 
      end

      specify 'Latin genus as Protonym with non-Latin name' do
        o = Otu.create!(taxon_name: genus, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><i>Aus</i> <b>sp1</b></span>') 
      end

      specify 'Latin family as Protonym with non-Latin name' do
        o = Otu.create!(taxon_name: family, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag">Familidae <b>sp1</b></span>') 
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_genus
        o = Otu.create!(taxon_name: genus, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><i>Aus</i> <b>sp1</b> <em>now</em> <i>Bus</i> <b>sp1</b></span>') 
      end
    end
  end 

  context 'all Latin' do
    context 'label' do
      specify 'Latin genus species as Combination' do
        combination.update!(species:)
        o = Otu.create!(taxon_name: combination)
        expect(helper.label_for_otu(o)).to eq('Aus bus [c]') 
      end

      specify 'Latin genus species as Protonym' do
        o = Otu.create!(taxon_name: species)
        expect(helper.label_for_otu(o)).to eq('Aus bus') 
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_species
        o = Otu.create!(taxon_name: species)
        expect(helper.label_for_otu(o)).to eq('Aus bus now Aus dus') 
      end
    end 

    context 'tag' do
      specify 'Latin genus species as Combination' do
        combination.update!(species:)
        o = Otu.create!(taxon_name: combination)
        expect(helper.label_for_otu(o)).to eq("<span class=\"otu_tag\"><i>Aus bus</i> #{TaxonNamesHelper::COMBINATION_MARK}</span>") 
      end

      specify 'Latin genus species as Protonym' do
        o = Otu.create!(taxon_name: species)
        expect(helper.label_for_otu(o)).to eq('<span class="otu_tag"><i>Aus bus</i></span>') 
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_species
        o = Otu.create!(taxon_name: species)
        expect(helper.label_for_otu(o)).to eq('<span class="otu_tag"><i>Aus bus</i> <em>now</em> <i>Aus dus</i></span>') 
      end
    end 
  end 

  context 'no Latin' do
    let(:b) { 'BIN 12321' }

    context 'label' do
      specify 'Latin genus species as Combination' do
        combination.update!(species:)
        o = Otu.create!(name: 'undescribed X', taxon_name: combination)
        expect(helper.label_for_otu(o)).to eq('undescribed x == Aus bus') 
      end

      specify 'Latin genus species as Protonym' do
        o = Otu.create!(name: b, taxon_name: genus)
        expect(helper.label_for_otu(o)).to eq("Aus #{b}") 
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_genus
        o = Otu.create!(name: b, taxon_name: genus)
        expect(helper.label_for_otu(o)).to eq("Aus #{b} now Bus #{b}") 
      end
    end 

    context 'tag' do
      specify 'Latin genus species as Combination' do
        combination.update!(species:)
        o = Otu.create!(name: 'undescribed X', taxon_name: combination)
        expect(helper.label_for_otu(o)).to eq('<span class="otu_tag"><b>undescribed x</b> <em>==<em> <i>Aus bus</i></span>') 
      end

      specify 'Latin genus species as Protonym' do
        o = Otu.create!(name: b, taxon_name: genus)
        expect(helper.label_for_otu(o)).to eq("<span class=\"otu_tag\"><i>Aus</i> <b>#{b}</b></span>") 
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_genus
        o = Otu.create!(name: b, taxon_name: genus)
        expect(helper.label_for_otu(o)).to eq("<span class=\"otu_tag\"><i>Aus</i> <b>#{b}</b> <em>now</em> <i>Bus</i> <b>#{b}</b></span>") 
      end

      specify 'Non latin name, no TaxonName' do
        o = Otu.create!(name: b)
        expect(helper.label_for_otu(o)).to eq("<span class=\"otu_tag\"><b>#{b}</b></span>") 
      end
    end 

  end 
end
