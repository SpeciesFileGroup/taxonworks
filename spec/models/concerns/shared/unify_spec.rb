require 'rails_helper'

describe 'Shared::Unify', type: :model do

  specify '#unify' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)
    expect(o1.unify(o2)).to be_truthy
  end

  specify 'unify destroys by default' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    o1.unify(o2)
    expect(o2.destroyed?).to be_truthy
  end

  specify 'unify does not destroy with preview' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    o1.unify(o2, preview: true)
    expect(o2.destroyed?).to be_falsey
  end

  specify 'unify moves annotations' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)
    n = FactoryBot.create(:valid_note, note_object: o2)

    o1.unify(o2)
    expect(o1.notes.reload.count).to eq(1)
  end

  specify 'unify moves has_many' do
    s = FactoryBot.create(:valid_specimen)
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)
    n = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, otu: o2)

    o1.unify(o2)
    expect(o1.taxon_determinations.reload.count).to eq(1)
  end

  specify '#identical' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    ad1 = FactoryBot.create(:valid_asserted_distribution, otu: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, otu: o2, geographic_area: ad1.geographic_area)

    ad2.otu = o1

    expect(ad2.identical.first).to eq(ad1)
  end

  #
  # Model/Context specific handling
  #

  specify 'unify handles Auto UUIDs' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    o1.unify(o2)

    expect(o1.identifiers.reload.size).to eq(2)
  end

  # See also TNR
  #  When we loop through as has_many
  #     and we are updating a record A
  #      and it fails with an error * on the class being unified *
  #         then we find the identical duplicate record B
  #             and we unify A -> B
  #               and we delete A
  #
  specify 'unify one degree of seperation' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    ad1 = FactoryBot.create(:valid_asserted_distribution, otu: o1)
    ad2 = FactoryBot.create(:valid_asserted_distribution, otu: o2, geographic_area: ad1.geographic_area) # differ only by OTU

    n = FactoryBot.create(:valid_note, note_object: ad1)

    b = o1.unify(o2)

    expect(AssertedDistribution.find_by(id: ad2.id)).to eq(nil)
    expect(n.reload.note_object).to eq(ad1)
    expect(o2.destroyed?).to be_truthy
  end

  # Generalize to all annotations.
  # 
  # If unify would create two identical citations anywhere
  # during the process, then destroy one of them.
  #
  #   then destroy one of them 
  #
  #
  #
  specify 'would-be duplicate citations do not halt unify' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    s = FactoryBot.create(:valid_source)

    ad1 = FactoryBot.create(:valid_asserted_distribution, otu: o1, source: s)
    ad2 = FactoryBot.create(:valid_asserted_distribution, otu: o2, geographic_area: ad1.geographic_area, source: s) 

    expect(Citation.all.size).to eq(2)
    
    b = o1.unify(o2)

    expect(o2.destroyed?).to be_truthy
    expect(Citation.all.size).to eq(1)
  end

end

class TestUnify < ApplicationRecord
  include FakeTable
  include Shared::Unify
end

