require 'rails_helper'

RSpec.describe Lead, type: :model do

  before(:all) do
    Lead.delete_all
  end

  let(:lead) { FactoryBot.create(:valid_lead) }

  specify '#destroy_couplet destroys when one child' do
    FactoryBot.create(:valid_lead, parent: lead)
    lead.destroy_couplet
    expect(Lead.count).to eq(1)
  end

  specify '#insert_couplet adds a couplet' do
    lead.insert_couplet
    expect(Lead.count).to eq(3)
  end

  specify '#insert_couplet children are ordered' do
    ids = lead.insert_couplet
    expect(Lead.find(ids[0]).position).to eq(0)
    expect(Lead.find(ids[1]).position).to eq(1)
  end

  specify '#insert_couplet inserts between leads' do
    FactoryBot.create(:valid_lead, parent: lead)
    lead.insert_couplet
    expect(Lead.count).to eq(4)
  end

  specify '#insert_couplet between leads inserts with positions' do
    FactoryBot.create(:valid_lead, parent: lead, text: 'bottom')
    lead.reload.insert_couplet
    a = lead.children.reload.order(:position)

    expect(a.first.children.size).to eq(1)
  end

  specify '#insert_couplet between leads with siblings inserts couplets ' do
    FactoryBot.create(:valid_lead, parent: lead, text: 'bottom left')
    FactoryBot.create(:valid_lead, parent: lead, text: 'bottom right')

    lead.reload.insert_couplet

    a = lead.reload.children.order(:position)
    expect(a.first.children.size).to eq(2)
  end

  specify '#insert_couplet between leads with siblings maintains position' do
    bl = FactoryBot.create(:valid_lead, parent: lead, text: 'bottom left')
    br = FactoryBot.create(:valid_lead, parent: lead, text: 'bottom right')

    lead.reload.insert_couplet

    expect(bl.reload.position).to be < br.reload.position
  end

  specify '#node_position of root' do
    expect(lead.node_position).to eq(:root)
  end

  specify '#node_position with three leea children' do
    a = FactoryBot.create(:valid_lead, parent: lead)
    b = FactoryBot.create(:valid_lead, parent: lead)
    c = FactoryBot.create(:valid_lead, parent: lead)

    expect(a.node_position).to eq(:left)
    expect(b.node_position).to eq(:middle)
    expect(c.node_position).to eq(:right)
  end

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

  # TODO: should this be a request test instead, so that we're testing
  # whatever current leads_controller#update behavior is?
  specify "'ui update' doesn't change order of chidren" do
    # Simulate a ui 'Update' saving all three nodes of a couplet.
    l = FactoryBot.create(:valid_lead, parent: lead, text: 'bottom left')
    r = FactoryBot.create(:valid_lead, parent: lead, text: 'bottom right')

    lead.update! text: lead.text
    l.update! text: 'new text'
    r.update! text: r.text

    expect(l.reload.position).to be < r.reload.position
  end

  xspecify "keys with external referrers can't be destroyed" do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    child = root1.children.create!(text: 'c')
    expect(child.update!(redirect_id: root2.id)).to be(true)
    expect{root2.destroy!}.to raise_error ActiveRecord::RecordNotDestroyed
  end

  xspecify "keys with internal referrers can't be destroyed" do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create! text: 'c'
    sibling = root.children.create! text: 's'
    expect(child.update! redirect_id: sibling.id).to be(true)
    # TODO: this may depend on the order in which the children get destroyed:
    # if the child with !redirect_id.nil? gets destroyed first then there
    # may be no error (which would be fine!).
    expect{root.destroy!}.to raise_error ActiveRecord::RecordNotDestroyed
  end

  context 'Retrieving roots data using roots_with_data' do
    specify 'returns the right number of roots' do
      lead.insert_couplet
      root2 = FactoryBot.create(:valid_lead)
      root2.insert_couplet

      q = Lead.roots_with_data(project_id)
      expect(q.map { |r| r.parent_id }).to eq([nil, nil])
    end

    specify 'returns roots from the right project' do
      root1 = FactoryBot.create(:valid_lead)

      p2 = FactoryBot.create(:valid_project)
      root2 = FactoryBot.create(:valid_lead, project_id: p2.id)

      q = Lead.roots_with_data(project_id)
      expect(q.map { |r| r.project_id }).to eq([project_id])
    end

    specify 'returns roots ordered by text' do
      root1 = FactoryBot.create(:valid_lead, text: 'b')
      root2 = FactoryBot.create(:valid_lead, text: 'c')
      root3 = FactoryBot.create(:valid_lead, text: 'a')

      q = Lead.roots_with_data(project_id)
      expect(q.map { |r| r.text }). to eq(['a', 'b', 'c'])
    end

    specify 'returns couplet_count' do
      ids = lead.insert_couplet
      Lead.find(ids[0]).insert_couplet

      q = Lead.roots_with_data(project_id)
      expect(q.first.couplet_count).to eq(2)
    end

    specify 'returns otus_count' do
      ids = lead.insert_couplet
      otu1 = FactoryBot.create(:valid_otu)
      otu2 = FactoryBot.create(:valid_otu)
      lead.update! otu_id: otu1.id
      Lead.find(ids[0]).update! otu_id: otu2.id

      q = Lead.roots_with_data(project_id)
      expect(q.first.otus_count).to eq(2)
    end

    specify 'returns correct key_updated_at' do
      child = FactoryBot.create(:valid_lead)
      lead.add_child child
      child.update! text: 'new text'

      q = Lead.roots_with_data(project_id)
      expect(q.first.key_updated_at).to eq(child.updated_at)
    end

    specify 'returns correct key_updated_by_id' do
      # The update we'll do on a child later will be as Current.user_id, so
      # create a root with a different updated_by_id so we can differentiate.
      user2 = FactoryBot.create(:valid_user)
      user2_root = FactoryBot.create(:valid_lead, updated_by_id: user2.id)

      child = FactoryBot.create(:valid_lead)
      user2_root.add_child child
      # Updates as Current.user_id (not as user2)
      child.update! text: 'new text'

      q = Lead.roots_with_data(project_id)
      expect(user2_root.updated_by_id).to eq(user2.id)
      expect(q.first.key_updated_by_id).to eq(Current.user_id)
    end

    specify 'returns correct key_updated_by' do
       # The update we'll do on a child later will be as Current.user_id, so
      # create a root with a different updated_by_id so we can differentiate.
      user2 = FactoryBot.create(:valid_user)
      user2_root = FactoryBot.create(:valid_lead, updated_by_id: user2.id)

      child = FactoryBot.create(:valid_lead)
      user2_root.add_child child
      # Updates as Current.user_id (not as user2)
      child.update! text: 'new text'

      q = Lead.roots_with_data(project_id)
      expect(user2_root.updated_by_id).to eq(user2.id)
      child_updated_by_name = User.find(child.updated_by_id).name
      expect(q.first.key_updated_by).to eq(child_updated_by_name)
    end

    specify "doesn't pre-load otus when you don't tell it to" do
      otu = FactoryBot.create(:valid_otu)

      lead.update! otu_id: otu.id

      q = Lead.roots_with_data(project_id)
      expect(q.first.association(:otu).loaded?).to be(false)
    end

    specify 'pre-loads otus when you tell it to' do
      otu = FactoryBot.create(:valid_otu)

      lead.update! otu_id: otu.id

      q = Lead.roots_with_data(project_id, true)
      expect(q.first.association(:otu).loaded?).to be(true)
    end

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

    specify 'current positions are correct after #insert_couplet (left)' do
      ids = l.insert_couplet
      expect(Lead.find_by(text: 'l').position).to be < Lead.find_by(text: 'r').position   # Position shouldn't change L or R
    end

    specify 'inserted lead positions are correct after #insert_couplet (left)' do
      ids = l.insert_couplet
      a = Lead.find(ids[0])
      expect(Lead.find(ids[0]).reload.position).to be < Lead.find(ids[1]).reload.position               # Children should be left/right OK
    end

    specify 're-attached child lead positions are correct after #insert_couplet (left)' do
      ids = l.insert_couplet
      expect(Lead.find_by(text: 'll').position).to be < Lead.find_by(text: 'lr').position # Grand children maintain position
    end

    specify 'current positions are correct after #insert_couplet (right)' do
      ids = lr.insert_couplet
      expect(Lead.find_by(text: 'll').position).to be < Lead.find_by(text: 'lr').position   # Position shouldn't change L or R
    end

    specify 'inserted lead positions are correct after #insert_couplet (right)' do
      ids = lr.insert_couplet
      a = Lead.find(ids[0])
      expect(Lead.find(ids[0]).reload.position).to be < Lead.find(ids[1]).reload.position               # Children should be left/right OK
    end

    specify 're-attached child lead positions are correct after #insert_couplet (right)' do
      ids = lr.insert_couplet
      expect(Lead.find_by(text: 'lrl').position).to be < Lead.find_by(text: 'lrr').position # Grand children maintain position
    end

    specify 'insert_couplet reparents on the right if self was a right child' do
      # lr is a right child, so reparented children should be on right.
      ids = lr.insert_couplet

      expect(Lead.find(ids[0]).children.size).to eq(0)
      expect(Lead.find(ids[1]).all_children.size).to eq(2)

      expect(Lead.find(ids[0]).text).to eq('Inserted node')
      expect(Lead.find(ids[1]).text).to eq('Child nodes are attached to this node')
    end

    specify 'insert_couplet reparents on the right if self was a right child' do
      # l is a left child, so reparented children should be on left.
      ids = l.insert_couplet

      expect(Lead.find(ids[0]).all_children.size).to eq(4)
      expect(Lead.find(ids[1]).children.size).to eq(0)

      expect(Lead.find(ids[0]).text).to eq('Child nodes are attached to this node')
      expect(Lead.find(ids[1]).text).to eq('Inserted node')
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

    specify '#transaction_nuke nukes' do
      second_key = FactoryBot.create(:valid_lead)
      second_key.insert_couplet

      expect(Lead.all.size).to eq(10)

      expect(root.transaction_nuke).to be_truthy
      expect(Lead.all.reload.size).to eq(3)
      expect(Lead.find(second_key.id)).to eq(second_key)
    end

    specify 'nuke destroys all children of a key' do
      second_key = FactoryBot.create(:valid_lead)
      second_key.insert_couplet

      expect(Lead.all.size).to eq(10)
      expect(root.nuke).to be_truthy
      expect(Lead.all.reload.size).to eq(3)
    end

    specify '#nuke leaves other keys alone' do
      second_key = FactoryBot.create(:valid_lead)
      second_key.insert_couplet
      root.nuke
      expect(Lead.all.reload.size).to eq(3)
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

    specify "destroy_couplet doesn't change order of parent node pair (left)" do
      l.destroy_couplet
      expect(Lead.find_by(text: 'l').position).to be < Lead.find_by(text: 'r').position
    end

    specify "destroy_couplet doesn't change order of reparented nodes (left)" do
      l.destroy_couplet
      expect(Lead.find_by(text: 'lrl').position).to be < Lead.find_by(text: 'lrr').position
    end

    specify "destroy_couplet doesn't change order of parent node pair (right)" do
      rl = r.children.create! text: 'rl'
      rr = r.children.create! text: 'rr'
      rll = rl.children.create! text: 'rll'
      rlr = rl.children.create! text: 'rlr'

      r.reload.destroy_couplet
      expect(Lead.find_by(text: 'l').position).to be < Lead.find_by(text: 'r').position
    end

    specify "destroy_couplet doesn't change order of reparented nodes (right)" do
      rl = r.children.create! text: 'rl'
      rr = r.children.create! text: 'rr'
      rll = rl.children.create! text: 'rll'
      rlr = rl.children.create! text: 'rlr'

      r.reload.destroy_couplet
      expect(Lead.find_by(text: 'rll').position).to be < Lead.find_by(text: 'rlr').position
    end

    specify "destroy_couplet doesn't change order of 3 reparented nodes (left)" do
      lrm = FactoryBot.create(:valid_lead, text: 'middle child of lr')
      lrl.append_sibling(lrm)

      l.reload.destroy_couplet

      expect(Lead.find_by(text: 'lrl').position).to be < Lead.find_by(text: 'middle child of lr').position
      expect(Lead.find_by(text: 'middle child of lr').position).to be < Lead.find_by(text: 'lrr').position
    end

    specify '#all_children' do
      lrll = lrl.children.create! text: 'lrll'
      lrlr = lrl.children.create! text: 'lrlr'
      expect(l.all_children.size).to eq(6)
    end

    specify '#destroy_couplet yields expected parent/child relationships' do
      # Test with grandchildren of l.
      lrll = lrl.children.create! text: 'lrll'
      lrlr = lrl.children.create! text: 'lrlr'

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
end
