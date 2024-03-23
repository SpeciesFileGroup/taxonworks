require 'rails_helper'

describe TaxonDetermination, type: :model, group: [:collection_objects] do

  let(:taxon_determination) {TaxonDetermination.new}
  let(:otu) { Otu.create!(name: 'Foo')  }
  let(:specimen) { Specimen.create! }

  specify 'after_save dwc_occurrence 1' do
    o1 = Otu.create!(taxon_name: FactoryBot.create(:iczn_species, name: 'ploz') )
    o2 = Otu.create!(taxon_name: FactoryBot.create(:iczn_species, name: 'froz') )

    specimen.taxon_determinations << TaxonDetermination.new(otu: o1)
    specimen.taxon_determinations << TaxonDetermination.new(otu: o2)

    expect(specimen.dwc_occurrence.is_stale?).to be_truthy
  end

  specify 'during save dwc_occurrence 2' do
    o1 = Otu.create!(taxon_name: FactoryBot.create(:iczn_species, name: 'ploz') )
    o2 = Otu.create!(taxon_name: FactoryBot.create(:iczn_species, name: 'froz') )

    s = Specimen.create!(taxon_determinations_attributes: [{otu: o1}, {otu: o2}])

    # hmmm - why passing
    expect(s.dwc_occurrence.reload.scientificName).to match(/froz/)
  end

  specify 'during save dwc_occurrence 3' do
    o1 = Otu.create!(taxon_name: FactoryBot.create(:iczn_species, name: 'ploz') )
    o2 = Otu.create!(taxon_name: FactoryBot.create(:iczn_species, name: 'froz') )
    s = Specimen.create!(taxon_determinations_attributes: [{otu: o1}, {otu: o2}])

    s.taxon_determinations.first.move_to_top # first is last (position)

    expect(s.dwc_occurrence.is_stale?).to be_truthy
  end

  specify '.batch_create' do
    params = {
      otu: FactoryBot.create(:valid_otu),
      by: user_id,
      project_id:
    }

    s1 = FactoryBot.create(:valid_specimen)
    s2 = FactoryBot.create(:valid_lot)

    r =  TaxonDetermination.batch_create([s1.id, s2.id], params)
    expect(r[:total_created]).to eq(2)
  end

  specify '.batch_create handles bad data' do
    params = {
      otu: nil,
      by: user_id,
      project_id:
    }

    s1 = FactoryBot.create(:valid_specimen)
    s2 = FactoryBot.create(:valid_lot)

    r =  TaxonDetermination.batch_create([s1.id, s2.id], params)
    expect(r[:failed]).to contain_exactly(s1.id, s2.id)
  end


  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(taxon_determination).to respond_to(:otu)
      end

      specify 'taxon_determination_object' do
        expect(taxon_determination).to respond_to(:taxon_determination_object)
      end
    end

    context 'has_many' do
      specify 'determiners' do
        expect(taxon_determination).to respond_to(:determiners)
      end

      specify 'determiners_organization' do
        expect(taxon_determination).to respond_to(:determiners_organization)
      end
    end
  end

  specify 'first determination has position "1"' do
    expect(FactoryBot.create(:valid_taxon_determination).position).to eq(1)
  end

  context 'multiple determinations' do
    let!(:a) {TaxonDetermination.create!(taxon_determination_object: specimen, otu:) }
    let!(:b) {TaxonDetermination.create!(taxon_determination_object: specimen, otu:) }

    specify 'two determinations, one deleted other has position "1"' do
      a.destroy!
      expect(b.reload.position).to eq(1)
    end

    specify 'two determinations, one deleted other has position "1", opposite' do
      b.destroy!
      expect(a.reload.position).to eq(1)
    end

    specify '#move_to_top is position 1' do
      expect(b.reload.position).to eq(1)
      a.move_to_top
      expect(a.reload.position).to eq(1)
    end

    specify 'last created is position 1' do
      expect(b.reload.position).to eq(1)
      expect(a.reload.position).to eq(2)
    end

    specify '.historical' do
      expect(TaxonDetermination.historical.map(&:id)).to contain_exactly(a.id)
    end

    specify '.current' do
      expect(TaxonDetermination.current.map(&:id)).to contain_exactly(b.id)
    end
  end

  context 'acts_as_list ordering of determinations' do
    let(:otu1) { FactoryBot.create(:valid_otu) }
    let(:otu2) { FactoryBot.create(:valid_otu) }

    before do
      specimen.taxon_determinations << TaxonDetermination.new(otu:)
    end

    specify 'determinations are added to the bottom of the stack with <<' do
      t = TaxonDetermination.new(otu: otu1)
      specimen.taxon_determinations << t
      expect(specimen.taxon_determinations.last.otu).to eq(otu1)
    end

    specify 'move a determination to the "current" position with #move_to_top' do
      t = TaxonDetermination.new(otu: otu1)
      specimen.taxon_determinations << t
      specimen.taxon_determinations.last.move_to_top
      expect(specimen.current_taxon_determination.otu).to eq(otu1)
    end
  end

  specify 'with an empty otu_id does not raise or create' do
    expect(Specimen.create!(taxon_determinations_attributes: [{otu_id: ''}])).to be_truthy
  end

  specify '#print_label is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n"
    taxon_determination.print_label = s
    taxon_determination.valid?
    expect(taxon_determination.print_label).to eq(s)
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'has_roles'
    it_behaves_like 'is_data'
  end

end
