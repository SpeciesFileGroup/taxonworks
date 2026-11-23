require 'rails_helper'

describe Autoselect::Otu::ColExistingOtu, type: :model do
  let(:m) { Autoselect::Otu::ColExistingOtu }

  let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
  let(:species) { subspecies.parent }

  def otu(name: nil)
    ::Otu.create!(taxon_name: species, name:, project_id:, by: user_id)
  end

  context '.otus_by_taxon_name' do
    specify 'maps each TaxonName with OTUs to all of them' do
      genus = species.ancestor_at_rank('genus')
      a = otu
      b = otu(name: 'named')
      expect(m.otus_by_taxon_name([species.id, genus.id, nil], project_id:))
        .to eq(species.id => [a, b])
    end

    specify 'is scoped to the project' do
      otu
      other_project_id = FactoryBot.create(:valid_project).id
      expect(m.otus_by_taxon_name([species.id], project_id: other_project_id))
        .to eq({})
    end
  end

  context '.selectable_otu' do
    specify 'nil without an OTU' do
      expect(m.selectable_otu([])).to be_nil
    end

    specify 'the only OTU, when it has no name of its own' do
      plain = otu
      expect(m.selectable_otu([plain])).to eq(plain)
    end

    specify 'the only OTU, even when it has a name of its own' do
      named = otu(name: 'sp. 1')
      expect(m.selectable_otu([named])).to eq(named)
    end

    specify 'the one OTU with no name of its own, among named ones' do
      plain = otu
      expect(m.selectable_otu([otu(name: 'sp. 1'), plain, otu(name: 'sp. 2')]))
        .to eq(plain)
    end

    specify 'nil when several OTUs have no name of their own' do
      expect(m.selectable_otu([otu, otu, otu(name: 'sp. 1')])).to be_nil
    end

    specify 'nil when every OTU has a name of its own' do
      expect(m.selectable_otu([otu(name: 'sp. 1'), otu(name: 'sp. 2')]))
        .to be_nil
    end
  end

  context '.hook' do
    let(:base) { { create_url: '/otus/autoselect_col_create', yields: 'otu_id' } }

    specify 'carries the only, unnamed, OTU as the existing one' do
      plain = otu
      expect(m.hook([plain])).to eq(base.merge(
        existing_id: plain.id, existing_global_id: plain.to_global_id.to_s,
        existing_named: false, taxon_name_id: species.id, otu_count: 1,
        otu_label: ApplicationController.helpers.label_for_otu(plain)
      ))
    end

    specify 'carries the only OTU, flagged as named, when it has a name' do
      named = otu(name: 'sp. 1')
      expect(m.hook([named])).to eq(base.merge(
        existing_id: named.id, existing_global_id: named.to_global_id.to_s,
        existing_named: true, taxon_name_id: species.id, otu_count: 1,
        otu_label: ApplicationController.helpers.label_for_otu(named)
      ))
    end

    specify 'carries the unnamed OTU, its label, and the total, among named ones' do
      plain = otu
      expect(m.hook([plain, otu(name: 'sp. 1')])).to eq(base.merge(
        existing_id: plain.id, existing_global_id: plain.to_global_id.to_s,
        existing_named: false, taxon_name_id: species.id, otu_count: 2,
        otu_label: ApplicationController.helpers.label_for_otu(plain)
      ))
    end

    specify 'has no existing OTU, and the count, with several named ones' do
      expect(m.hook([otu(name: 'sp. 1'), otu(name: 'sp. 2')])).to eq(base.merge(
        existing_id: nil, existing_global_id: nil, existing_named: false,
        taxon_name_id: species.id, otu_count: 2, otu_label: nil
      ))
    end

    specify 'has nil fields and a zero count without one' do
      expect(m.hook([])).to eq(base.merge(
        existing_id: nil, existing_global_id: nil, existing_named: false,
        taxon_name_id: nil, otu_count: 0, otu_label: nil
      ))
    end
  end

  context '.find_or_create_for' do
    def call
      m.find_or_create_for(species.id, project_id:, user_id:)
    end

    specify 'creates an OTU when the name has none' do
      expect { call }.to change(::Otu, :count).by(1)
      expect(call.taxon_name_id).to eq(species.id)
    end

    specify 'returns the only OTU when it has no name of its own' do
      plain = otu
      expect(call).to eq(plain)
    end

    specify 'returns the only OTU, even when it has a name of its own' do
      named = otu(name: 'sp. 1')
      expect(call).to eq(named)
    end

    specify 'returns the unnamed OTU among named ones' do
      plain = otu
      otu(name: 'sp. 1')
      expect(call).to eq(plain)
    end

    specify 'raises, creating nothing, when every OTU is named' do
      otu(name: 'sp. 1')
      otu(name: 'sp. 2')
      expect { call rescue nil }.not_to change(::Otu, :count)
      expect { call }.to raise_error(described_class::AmbiguousOtuError, /2 OTUs/)
    end

    specify 'raises when several OTUs have no name of their own' do
      otu
      otu
      expect { call }.to raise_error(described_class::AmbiguousOtuError)
    end
  end
end
