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
    child = root.children.create! text: 'c'
    grandchild = child.children.create! text: 'gc'

    root2 = FactoryBot.create(:valid_lead)
    expect { child.update! redirect_id: root2.id }.to raise_error ActiveRecord::RecordInvalid
  end

  specify 'children of a redirect node are invalid' do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    child = root1.children.create! text: 'c'
    expect(child.new_record?).to be(false)
    expect(child.update! redirect_id: root2.id).to be(true)
    expect(child.valid?).to be(true)
    expect{child.children.create! text: 'gc'}.to raise_error ActiveRecord::RecordInvalid
  end

  specify "redirect can't point to an ancestor" do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create! text: 'c'
    expect {child.update! redirect_id: root.id}.to raise_error ActiveRecord::RecordInvalid
  end

  specify "keys with external referrers can't be destroyed" do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    child = root1.children.create! text: 'c'
    expect(child.update! redirect_id: root2.id).to be(true)
    expect{root2.destroy!}.to raise_error ActiveRecord::RecordNotDestroyed
  end

  specify "keys with internal referrers can't be destroyed" do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create! text: 'c'
    sibling = root.children.create! text: 's'
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

    specify 'positions are correct after insert_couplet' do
      ids = l.insert_couplet

      expect(Lead.find_by(text: 'l').position).to be < Lead.find_by(text: 'r').position
      expect(Lead.find(ids[0]).position).to be < Lead.find(ids[1]).position
      expect(Lead.find_by(text: 'll').position).to be < Lead.find_by(text: 'lr').position

      # Test the same when inserting on a right node.
      ids = lr.insert_couplet

      expect(Lead.find_by(text: 'll').position).to be < Lead.find_by(text: 'lr').position
      expect(Lead.find(ids[0]).position).to be < Lead.find(ids[1]).position
      expect(Lead.find_by(text: 'lrl').position).to be < Lead.find_by(text: 'lrr').position
    end

    specify 'insert_couplet reparents on the same side as self' do
      # lr is a right child, so reparented children should be on right.
      ids = lr.insert_couplet

      expect(Lead.find(ids[0]).children.size).to eq(0)
      expect(Lead.find(ids[1]).all_children.size).to eq(2)

      expect(Lead.find(ids[0]).text). to eq('Inserted node')
      expect(Lead.find(ids[1]).text).to eq('Child nodes are attached to this node')

      # l is a left child, so reparented children should be on left.
      ids = l.insert_couplet

      expect(Lead.find(ids[0]).all_children.size).to eq(6)
      expect(Lead.find(ids[1]).children.size).to eq(0)

      expect(Lead.find(ids[0]).text).to eq('Child nodes are attached to this node')
      expect(Lead.find(ids[1]).text). to eq('Inserted node')
    end

    specify 'insert_couplet creates expected parent/child relationships' do
      expect(lr.all_children.size).to eq(2)

      ids = lr.insert_couplet
      lr.reload

      new_left_child = Lead.find(ids[0])
      new_right_child = Lead.find(ids[1])

      expect(lr.children[0]).to eq(new_left_child)
      expect(lr.children[1]).to eq(new_right_child)

      expect(new_left_child.children.size).to eq(0)

      expect(new_right_child.children[0]).to eq(Lead.find_by(text: 'lrl'))
      expect(new_right_child.children[1]).to eq(Lead.find_by(text: 'lrr'))

      expect(new_left_child.parent_id).to eq(lr.id)
      expect(new_right_child.parent_id).to eq(lr.id)
      expect(Lead.where(parent_id: ids[0]).size).to be(0)
      expect(Lead.where(parent_id: ids[1]).size).to be(2)
      expect(Lead.find_by(text: 'lrl').parent_id).to eq(ids[1])
      expect(Lead.find_by(text: 'lrr').parent_id).to eq(ids[1])
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

    specify 'destroy_couplet noops on a couplet with no children' do
      expect(Lead.find_by(text: 'r').destroy_couplet).to be(true)
      expect(Lead.where('parent_id is null').first.all_children.size).to be(6)
    end

    specify "destroy_couplet doesn't change order of remaining nodes" do
      l.destroy_couplet

      expect(Lead.find_by(text: 'l').position).to be < Lead.find_by(text: 'r').position
      expect(Lead.find_by(text: 'lrl').position).to be < Lead.find_by(text: 'lrr').position

      # Test the same for destroy_couplet on a right node.
      r.reload
      rl = r.children.create! text: 'rl'
      rr = r.children.create! text: 'rr'
      rll = rl.children.create! text: 'rll'
      rlr = rl.children.create! text: 'rlr'

      Lead.find_by(text: 'r').destroy_couplet
      expect(Lead.find_by(text: 'l').position).to be < Lead.find_by(text: 'r').position
      expect(Lead.find_by(text: 'rll').position).to be < Lead.find_by(text: 'rlr').position
    end

    specify 'destroy_couplet yields expected parent/child relationships' do
      # Test with grandchildren of l.
      lrll = lrl.children.create! text: 'lrll'
      lrlr = lrl.children.create! text: 'lrlr'
      expect(l.all_children.size).to eq(6)

      expect(l.destroy_couplet).to be(true)
      l.reload
      lrl.reload
      lrr.reload
      lrll.reload
      lrlr.reload

      expect(l.all_children.size).to eq(4)
      expect(l.children[0]).to eq(lrl)
      expect(l.children[1]).to eq(lrr)
      expect(lrl.children[0]).to eq(lrll)
      expect(lrl.children[1]).to eq(lrlr)
      expect(lrr.children.size).to eq(0)

      expect(Lead.where(parent_id: l.id).size).to be(2)
      expect(Lead.where(parent_id: lrl.id).size).to be(2)
      expect(Lead.where(parent_id: lrr.id).size).to be(0)
      expect(lrl.parent_id).to eq(l.id)
      expect(lrr.parent_id).to eq(l.id)
      expect(lrll.parent_id).to eq(lrl.id)
      expect(lrlr.parent_id).to eq(lrl.id)
    end
  end

  context 'with one couplet' do
    let!(:root) { FactoryBot.create(:valid_lead) }
    let!(:l) { root.children.create!(text: 'l') }
    let!(:r) { root.children.create!(text: 'r') }
    let(:user) { FactoryBot.create(:valid_user) }

    specify 'root updated_at is updated when descendant updated_at is updated' do
      start_time = root.updated_at
      l.update! text: 'new text'
      root.reload
      expect(root.updated_at).to be > start_time
    end

    specify 'root updated_by is updated when descendant update_by is updated' do
      expect(root.updated_by_id).not_to eq(user.id)
      l.update! text: 'new text', updated_by_id: user.id
      root.reload
      expect(root.updated_by_id).to eq(user.id)
    end

    specify 'root updated_at is updated when a descendant is added' do
      start_time = root.updated_at
      l.children.create! text:'ll'
      root.reload
      expect(root.updated_at).to be > start_time
    end

    specify "unchanged update doesn't overwrite changed update" do
      # When we update in the ui, each of the 3 leads in a couplet gets
      # updated. Test that if left has changes but right doesn't, that
      # updating root with left's update data doesn't get overwritten by
      # right's old (unchanged) update data.
      start_time = root.updated_at
      l.update! text: 'new text'

      before_right_update = Time.now.utc
      right_start_time = r.updated_at
      # An update with no change (this shouldn't update root):
      r.update! text: r.text
      r.reload
      expect(r.updated_at).to eq(right_start_time)

      root.reload
      expect(root.updated_at).to be > start_time
      expect(root.updated_at).to be < before_right_update
    end

    specify 'delete node updates root.updated_at' do
      l.children.create! text: 'll'
      l.children.create! text: 'lr'

      root.reload
      start_time = root.updated_at
      l.destroy_couplet

      root.reload
      expect(root.updated_at).to be > start_time
    end

    specify 'delete node updates root.updated_by_id' do
      l.children.create! text: 'll'
      l.children.create! text: 'lr'

      root.update! updated_by_id: user.id
      root.reload
      original_updated_by_id = root.updated_by_id

      l.destroy_couplet

      root.reload
      expect(root.updated_by_id).not_to eq(original_updated_by_id)
      expect(root.updated_by_id).to eq(Current.user_id)
    end
  end
end
