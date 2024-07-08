require 'rails_helper'

describe 'Shared::Unify', type: :model do

  specify 'unify' do
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
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)
    n = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: o2)
   
    o1.unify(o2)
    expect(o1.taxon_determinations.reload.count).to eq(1)
  end

end

class TestUnify < ApplicationRecord
  include FakeTable
  include Shared::Unify
end

