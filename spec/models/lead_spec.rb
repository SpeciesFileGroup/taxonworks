require 'rails_helper'

RSpec.describe Lead, type: :model do
  specify 'new key has nil parent' do
    k = Lead.new
    expect(k.parent_id).to be(nil)
  end

  specify 'is_public is only set on roots' do
    root = Lead.create! text: 'private key'
    expect(root.is_public).to be(false)

    c1_id, c2_id = root.insert_couplet
    c1 = Lead.find(c1_id)
    expect(c1.is_public).to be(nil)
    c1.update!(is_public: true)
    expect(c1.is_public).to be(nil)

    public_root = Lead.create! text: 'public key', is_public: true
    expect(public_root.is_public).to be(true)
  end

  specify 'no redirect on root nodes' do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    expect { root2.update! redirect_id: root1.id }.to raise_error ActiveRecord::RecordInvalid
  end

  specify 'redirect only on leaf nodes' do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create text: 'c'
    grandchild = child.children.create text: 'gc'

    root2 = FactoryBot.create(:valid_lead)
    expect { child.update! redirect_id: root2.id }.to raise_error ActiveRecord::RecordInvalid
  end

  specify "children of a redirect node are invalid" do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    child = root1.children.create text: 'c'
    expect(child.new_record?).to be(false)
    expect(child.update! redirect_id: root2.id).to be(true)
    expect(child.valid?).to be(true)
    expect{child.children.create! text: 'gc'}.to raise_error ActiveRecord::RecordInvalid
  end

  specify "redirect can't point to an ancestor" do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create text: 'c'
    expect {child.update! redirect_id: root.id}.to raise_error ActiveRecord::RecordInvalid
  end

  specify "keys with external referrers can't be destroyed" do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    child = root1.children.create text: 'c'
    expect(child.update! redirect_id: root2.id).to be(true)
    expect{root2.destroy!}.to raise_error ActiveRecord::RecordNotDestroyed
  end

  specify "keys with internal referrers can't be destroyed" do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create text: 'c'
    sibling = root.children.create text: 's'
    expect(child.update! redirect_id: sibling.id).to be(true)
    # TODO: this may depend on the order in which the children get destroyed:
    # if the child with !redirect_id.nil? gets destroyed first then there
    # may be no error (which would be fine!).
    expect{root.destroy!}.to raise_error ActiveRecord::RecordNotDestroyed
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
      title = root.text
      expect(Lead.all.size).to eq(7)

      expect(root.dupe).to be_truthy

      expect(Lead.all.size).to eq(14)
      expect(Lead.where('parent_id is null').size).to eq(2)
      expect(Lead.where('parent_id is null').order(:id)[1].text).to eq('(COPY OF) ' + title)
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
