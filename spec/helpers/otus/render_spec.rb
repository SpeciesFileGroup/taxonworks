require 'rails_helper'

# TODO: add author year

describe OtusHelper, type: :helper do

  let(:otu) { Otu.create(name: 'voluptas') }

  specify '#otu_tag' do
    expect(helper.otu_tag(otu)).to eq(%(<span class="otu_tag">voluptas</span>))
  end

  specify '#otu_tag includes the authorship string of a linked taxon name' do
    taxon_name = FactoryBot.create(:relationship_species)

    taxon_name.update_columns(cached_html: '<i>Aus bus</i>', cached_author_year: '(Linnaeus, 1758)')
    named_otu = Otu.create!(taxon_name:)

    expect(helper.otu_tag(named_otu)).to include('(Linnaeus, 1758)')
  end

  specify '#otu_autoselect_tag includes the authorship string' do
    taxon_name = FactoryBot.create(:relationship_species)
    taxon_name.update_columns(cached_author_year: '(Linnaeus, 1758)')
    named_otu = Otu.create!(taxon_name:)

    expect(helper.otu_autoselect_tag(named_otu)).to match('(Linnaeus, 1758)')
  end

  # ----

  # Don't let!
  let(:root) { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
  let(:valid_genus) { Protonym.create!(name: 'Bus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }

  let(:species) { Protonym.create!(name: 'bus', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }
  let(:valid_species) { Protonym.create!(name: 'dus', parent: genus, rank_class: Ranks.lookup(:iczn, :species)) }

  let(:family) { Protonym.create!(name: 'Familidae', parent: root, rank_class: Ranks.lookup(:iczn, :family)) }

  let(:combination) { Combination.create!(genus:) }

  # "Functions"
  let(:synonymize_genus) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: genus, object_taxon_name: valid_genus) }
  let(:synonymize_species) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create(subject_taxon_name: species, object_taxon_name: valid_species) }

  context 'mixed Latin' do
    context 'label' do
      specify 'Latin genus as Combination with non-Latin name' do
        o = Otu.create!(taxon_name: combination, name: 'sp1')
        expect(helper.label_for_otu(o)).to eq('sp1 == Aus')
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
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag">sp1 <em>==</em> <span class="otu_tag_taxon_name"><i>Aus</i></span></span>')
      end

      specify 'Latin genus as Protonym with non-Latin name' do
        o = Otu.create!(taxon_name: genus, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><span class="otu_tag_taxon_name"><i>Aus</i></span>&nbsp;sp1</span>')
      end

      specify 'Latin family as Protonym with non-Latin name' do
        o = Otu.create!(taxon_name: family, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><span class="otu_tag_taxon_name">Familidae</span>&nbsp;sp1</span>')
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_genus
        o = Otu.create!(taxon_name: genus, name: 'sp1')
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><span class="otu_tag_taxon_name otu_tag_taxon_name_invalid"><i>Aus</i></span>&nbsp;sp1 <em>now</em> <span class="otu_tag_taxon_name"><i>Bus</i></span></span>')
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
        expect(helper.otu_tag(o)).to eq("<span class=\"otu_tag\"><span class=\"otu_tag_taxon_name\"><i>Aus bus</i></span> #{TaxonNamesHelper::COMBINATION_MARK}</span>")
      end

      specify 'Latin genus species as Protonym' do
        o = Otu.create!(taxon_name: species)
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><span class="otu_tag_taxon_name"><i>Aus bus</i></span></span>')
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_species
        o = Otu.create!(taxon_name: species)
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag"><span class="otu_tag_taxon_name otu_tag_taxon_name_invalid"><i>Aus bus</i></span> <em>now</em> <span class="otu_tag_taxon_name"><i>Aus dus</i></span></span>')
      end
    end
  end

  context 'no Latin' do
    let(:b) { 'BIN 12321' }

    context 'label' do
      specify 'Latin genus species as Combination' do
        combination.update!(species:)
        o = Otu.create!(name: 'undescribed X', taxon_name: combination)
        expect(helper.label_for_otu(o)).to eq('undescribed X == Aus bus')
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
        expect(helper.otu_tag(o)).to eq('<span class="otu_tag">undescribed X <em>==</em> <span class="otu_tag_taxon_name"><i>Aus bus</i></span></span>')
      end

      specify 'Latin genus species as Protonym' do
        o = Otu.create!(name: b, taxon_name: genus)
        expect(helper.otu_tag(o)).to eq("<span class=\"otu_tag\"><span class=\"otu_tag_taxon_name\"><i>Aus</i></span>&nbsp;#{b}</span>")
      end

      specify 'Latin genus as invalid Protonym with non-Latin name' do
        synonymize_genus
        o = Otu.create!(name: b, taxon_name: genus)
        expect(helper.otu_tag(o)).to eq("<span class=\"otu_tag\"><span class=\"otu_tag_taxon_name otu_tag_taxon_name_invalid\"><i>Aus</i></span>&nbsp;#{b} <em>now</em> <span class=\"otu_tag_taxon_name\"><i>Bus</i></span></span>")
      end

      specify 'Non latin name, no TaxonName' do
        o = Otu.create!(name: b)
        expect(helper.otu_tag(o)).to eq("<span class=\"otu_tag\">#{b}</span>")
      end
    end

  end
end
