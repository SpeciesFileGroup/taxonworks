require 'rails_helper'

RSpec.describe Lead, type: :model do
  specify 'new key has nil parent' do
    k = Lead.new
    expect(k.parent_id).to be(nil)
  end

  context 'with multiple couplets' do
    before(:all) do
      Lead.delete_all
    end

    #      root
    #     /    \
    #    l      r
    #   / \
    # ll   lr
    #     /  \
    #   lrl  lrr
    let!(:root) { FactoryBot.create(:valid_lead) }
    let!(:l) { root.children.create!(text: 'l') }
    let!(:r) { root.children.create!(text: 'r') }
    let!(:ll) { l.children.create!(text: 'll') }
    let!(:lr) { l.children.create!(text: 'lr') }
    let!(:lrl) { lr.children.create!(text: 'lrl') }
    let!(:lrr) { lr.children.create!(text: 'lrr') }

    specify 'future honors redirect' do
      expect(r.future.size).to be(0)
      r.redirect_id = lr.id
      expect(r.future.size).to be(2)
      expect(r.future.first[:cpl].text).to eq('lrr')
    end

    specify 'dupe' do
      expect(Lead.all.size).to eq(7)

      expect(root.dupe).to be_truthy

      expect(Lead.all.size).to eq(14)
      expect(Lead.where('parent_id is null').size).to eq(2)
      expect(Lead.where('parent_id is null').order(:id)[1].description).to eq('(COPY)')
    end

    specify 'all_children' do
      expect(root.all_children.size).to eq(6)
      expect(root.all_children.first[:cpl].text).to eq('r')
      expect(root.all_children.last[:cpl].text).to eq('l')
      expect(l.all_children.size).to eq(4)
      expect(r.all_children.size).to eq(0)
    end

    specify 'all_children_standard_key' do
      expect(root.all_children_standard_key.size).to eq(6)
      expect(root.all_children_standard_key.first[:cpl].text).to eq('l')
      expect(root.all_children_standard_key.last[:cpl].text).to eq('lrr')
      expect(l.all_children_standard_key.size).to eq(4)
      expect(r.all_children_standard_key.size).to eq(0)
    end

    specify 'insert_couplet' do
      expect(lr.all_children.size).to eq(2)

      ids = lr.insert_couplet

      expect(Lead.find(ids[0]).text).to eq('Child nodes, if present, are attached to this node.')

      expect(Lead.find(ids[0]).all_children.size).to eq(2)
      expect(Lead.find(ids[1]).all_children.size).to eq(0)

      expect(Lead.find(ids[0]).children[0]).to eq(Lead.where(text: 'lrl')[0])
      expect(Lead.find(ids[0]).children[1]).to eq(Lead.where(text: 'lrr')[0])
      expect(Lead.find(ids[1]).children.size).to eq(0)

      expect(Lead.find(ids[0]).parent_id).to eq(lr.id)
      expect(Lead.find_by(text: 'lrl').parent_id).to eq(ids[0])
      expect(Lead.find_by(text: 'lrr').parent_id).to eq(ids[0])

      expect(Lead.find_by(text: 'lr').all_children.size).to eq(4)
    end

    specify 'destroy! destroys all children of a key' do
      second_key = FactoryBot.create(:valid_lead)
      second_key.insert_couplet
      expect(Lead.all.size).to eq(10)

      expect(root.destroy!).to be_truthy

      expect(Lead.all.size).to eq(3)
      expect(Lead.find(second_key.id)).to eq(second_key)
    end

    specify 'destroy_couplet noops when both children have children' do
      r.children.create!(text: 'rl')
      r.children.create!(text: 'rr')
      expect(Lead.where('parent_id is null').first.destroy_couplet).to be(false)
      expect(Lead.where('parent_id is null').first.all_children.size).to be(8)
    end

    specify 'destroy_couplet noops on a key with no children' do
      expect(Lead.find_by(text: 'r').destroy_couplet).to be(true)
      expect(Lead.where('parent_id is null').first.all_children.size).to be(6)
    end

    specify 'destroy_couplet' do
      lkey = Lead.find_by(text: 'l')
      expect(lkey.all_children.size).to eq(4)

      expect(lkey.destroy_couplet).to be(true)

      lkey2 = Lead.find_by(text: 'l')

      expect(lkey2.all_children.size).to eq(2)

      expect(Lead.find_by(text: 'lrl').parent_id).to eq(lkey2.id)
      expect(Lead.find_by(text: 'lrr').parent_id).to eq(lkey2.id)

      expect(lkey2.children[0]).to eq(Lead.find_by(text: 'lrl'))
      expect(lkey2.children[1]).to eq(Lead.find_by(text: 'lrr'))

      expect(lkey2.all_children.size).to eq(2)
    end
  end
end
