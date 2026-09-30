require 'rails_helper'

describe Autoselect::Otu::ColExistingOtu, type: :model do
  let(:m) { Autoselect::Otu::ColExistingOtu }

  let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
  let(:species) { subspecies.parent }

  context '.for_taxon_name' do
    specify 'nil when the TaxonName has no OTU' do
      expect(m.for_taxon_name(species.id, project_id:)).to be_nil
    end

    specify 'nil for a nil TaxonName id' do
      expect(m.for_taxon_name(nil, project_id:)).to be_nil
    end

    specify 'prefers the OTU without a name of its own' do
      ::Otu.create!(taxon_name: species, name: 'named', project_id:, by: user_id)
      plain = ::Otu.create!(taxon_name: species, project_id:, by: user_id)
      expect(m.for_taxon_name(species.id, project_id:)).to eq(plain)
    end

    specify 'otherwise the oldest' do
      oldest = ::Otu.create!(taxon_name: species, name: 'a', project_id:, by: user_id)
      ::Otu.create!(taxon_name: species, name: 'b', project_id:, by: user_id)
      expect(m.for_taxon_name(species.id, project_id:)).to eq(oldest)
    end

    specify 'is scoped to the project' do
      ::Otu.create!(taxon_name: species, project_id:, by: user_id)
      other_project_id = FactoryBot.create(:valid_project).id
      expect(m.for_taxon_name(species.id, project_id: other_project_id)).to be_nil
    end
  end

  context '.for_taxon_names' do
    specify 'maps each TaxonName with an OTU to it' do
      genus = species.ancestor_at_rank('genus')
      species_otu = ::Otu.create!(taxon_name: species, project_id:, by: user_id)
      expect(m.for_taxon_names([species.id, genus.id, nil], project_id:))
        .to eq(species.id => species_otu)
    end
  end

  context '.hook' do
    specify 'carries the existing OTU' do
      otu = ::Otu.create!(taxon_name: species, project_id:, by: user_id)
      expect(m.hook(otu)).to eq(
        create_url: '/otus/autoselect_col_create', yields: 'otu_id',
        existing_id: otu.id, existing_global_id: otu.to_global_id.to_s
      )
    end

    specify 'has nil existing fields without one' do
      expect(m.hook(nil)).to include(existing_id: nil, existing_global_id: nil)
    end
  end
end
