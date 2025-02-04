require 'rails_helper'
require 'export/coldp'

describe Export::Coldp, type: :model, group: :col do
  include ActiveJob::TestHelper

  specify 'otus' do
    p = FactoryBot.create(:valid_protonym)
    o = Otu.create!(taxon_name: p)
    expect(::Export::Coldp.otus(o.id).count).to eq(1)
  end

  context 'download packaging' do
    before { include ActiveJob::TestHelper }

    # We want the minimum data to have at least one, and hopefully as few as possible, lines in each export file.
    # Expand
    let!(:species) { FactoryBot.create(:iczn_species) }
    let(:otu) { Otu.create(taxon_name: species) }
    let!(:citation) { Citation.create!(citation_object: otu, source: FactoryBot.create(:valid_source_bibtex), is_original: true) }
    let!(:invalid_species) { Protonym.create(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: species.parent) }
    let!(:synonym) { TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: invalid_species, object_taxon_name: species) }
    let!(:common_name) { FactoryBot.create(:valid_common_name, otu: otu) }
    let!(:type_material) { FactoryBot.create(:valid_type_material, protonym: species) }
    let!(:asserted_distribution) { FactoryBot.create(:valid_asserted_distribution, otu: otu) }
    let!(:homonym_species) { Protonym.create(name: 'hus', rank_class: Ranks.lookup(:iczn, :species), parent: species.root) }
    let!(:homonym) { TaxonNameRelationship::Iczn::Invalidating::Homonym.create!(subject_taxon_name: homonym_species, object_taxon_name: species )  }
    let!(:biological_association) { FactoryBot.create(:valid_biological_association, biological_association_subject: otu, biological_association_object: Otu.create!(name: 'ba'))  }
    let!(:otu_relationship) { FactoryBot.create(:valid_otu_relationship, subject_otu: otu, object_otu:  Otu.create!(name: 'or'))  }

    let!(:d) {
      ::Export::Coldp.download_async(
        otu, 'https://example.org/some_url',
        prefer_unlabelled_otus: true
      )
    }

    specify '#download_async creates Download' do
      expect(Download.count).to eq(1)
    end

    specify '#download_async creates Zip after worker' do
      perform_enqueued_jobs
      expect(File.exist?(d.file_path)).to be_truthy
    end

    context 'when performed' do
      before { perform_enqueued_jobs }

      let!(:download) { Download.first }
      let!(:z) { Zip::File.open(download.file_path) }

      specify "includes tsv" do
        ::Export::Coldp::FILETYPES.each do |t|
          expect(z.find_entry("#{t}.tsv")).to be_truthy
        end
      end

      specify "writes to tsv" do
        ::Export::Coldp::FILETYPES.each do |t|
          c = z.find_entry("#{t}.tsv").get_input_stream.read.lines.count
          expect(c > 1).to be_truthy,  "Can't find #{t}.tsv"
        end
      end
    end
  end
end
