require 'rails_helper'

RSpec.describe Lead, type: :model do

  before(:all) do
    Lead.delete_all
  end

  let(:lead) { FactoryBot.create(:valid_lead) }

  specify '#destroy_children destroys when one child' do
    FactoryBot.create(:valid_lead, parent: lead)
    lead.reload.destroy_children
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

  specify '#insert_couplet between leads with siblings inserts couplets' do
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

  specify '#node_position with three lead children' do
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

  specify 'is_public gets set on roots' do
    public_root = Lead.create!(text: 'public key', is_public: true)
    expect(public_root.is_public).to be(true)
  end

  specify 'is_public is only set on roots' do
    root = Lead.create!(text: 'private key')
    expect(root.is_public).to be(false)

    ids = root.insert_couplet
    c1 = Lead.find(ids[0])
    expect(c1.is_public).to be(nil)
    c1.update!(is_public: true)
    expect(c1.is_public).to be(nil)
  end

  specify 'no redirect on root nodes' do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    expect { root2.update!(redirect_id: root1.id) }
      .to raise_error ActiveRecord::RecordInvalid
  end

  specify 'redirect only on leaf nodes' do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create!(text: 'c')
    _grandchild = child.children.create!(text: 'gc')

    root2 = FactoryBot.create(:valid_lead)
    expect { child.update!(redirect_id: root2.id) }
      .to raise_error ActiveRecord::RecordInvalid
  end

  specify 'children of a redirect node are invalid' do
    root1 = FactoryBot.create(:valid_lead)
    root2 = FactoryBot.create(:valid_lead)
    child = root1.children.create!(text: 'c')
    expect(child.new_record?).to be(false)
    expect(child.update!(redirect_id: root2.id)).to be(true)
    expect(child.valid?).to be(true)
    expect{ child.children.create!(text: 'gc') }
      .to raise_error ActiveRecord::RecordInvalid
  end

  specify "redirect can't point to an ancestor" do
    root = FactoryBot.create(:valid_lead)
    child = root.children.create!(text: 'c')
    expect {child.update!(redirect_id: root.id) }
      .to raise_error ActiveRecord::RecordInvalid
  end

  # TODO: should this be a request test instead, so that we're testing
  # whatever current leads_controller#update behavior is?
  specify "'ui update' doesn't change order of chidren" do
    # Simulate a ui 'Update' saving all three nodes of a couplet.
    l = FactoryBot.create(:valid_lead, parent: lead, text: 'bottom left')
    r = FactoryBot.create(:valid_lead, parent: lead, text: 'bottom right')

    lead.update!(text: lead.text)
    l.update!(text: 'new text')
    r.update!(text: r.text)

    expect(l.reload.position).to be < r.reload.position
  end

  context 'Retrieving roots data using ::roots_with_data' do
    specify 'returns the right number of roots' do
      lead.insert_couplet
      root2 = FactoryBot.create(:valid_lead)
      root2.insert_couplet

      q = Lead.roots_with_data(project_id)
      expect(q.map { |r| r.parent_id }).to eq([nil, nil])
    end

    specify 'returns roots from the right project' do
      _root1 = FactoryBot.create(:valid_lead)

      p2 = FactoryBot.create(:valid_project)
      _root2 = FactoryBot.create(:valid_lead, project_id: p2.id)

      q = Lead.roots_with_data(project_id)
      expect(q.map { |r| r.project_id }).to eq([project_id])
    end

    specify 'returns roots ordered by text' do
      FactoryBot.create(:valid_lead, text: 'b')
      FactoryBot.create(:valid_lead, text: 'c')
      FactoryBot.create(:valid_lead, text: 'a')

      q = Lead.roots_with_data(project_id)
      expect(q.map { |r| r.text }). to eq(['a', 'b', 'c'])
    end

    specify 'returns otus_count' do
      ids = lead.insert_couplet
      otu1 = FactoryBot.create(:valid_otu)
      otu2 = FactoryBot.create(:valid_otu)
      lead.update!(otu_id: otu1.id)
      Lead.find(ids[0]).update!(otu_id: otu2.id)

      q = Lead.roots_with_data(project_id)
      expect(q.first.otus_count).to eq(2)
    end

    specify 'returns correct key_updated_at' do
      child = FactoryBot.create(:valid_lead)
      lead.add_child(child)
      child.update!(text: 'new text')

      q = Lead.roots_with_data(project_id)
      expect(q.first.key_updated_at).to eq(child.updated_at)
    end

    specify 'returns correct key_updated_by_id' do
      # The update we'll do on a child later will be as Current.user_id, so
      # create a root with a different updated_by_id so we can differentiate.
      user2 = FactoryBot.create(:valid_user)
      user2_root = FactoryBot.create(:valid_lead, updated_by_id: user2.id)

      child = FactoryBot.create(:valid_lead)
      user2_root.add_child(child)
      # Updates as Current.user_id (not as user2)
      child.update!(text: 'new text')

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
      user2_root.add_child(child)
      # Updates as Current.user_id (not as user2)
      child.update!(text: 'new text')

      q = Lead.roots_with_data(project_id)
      expect(user2_root.updated_by_id).to eq(user2.id)
      child_updated_by_name = User.find(child.updated_by_id).name
      expect(q.first.key_updated_by).to eq(child_updated_by_name)
    end

    specify "doesn't pre-load otus when you don't tell it to" do
      otu = FactoryBot.create(:valid_otu)

      lead.update!(otu_id: otu.id)

      q = Lead.roots_with_data(project_id)
      expect(q.first.association(:otu).loaded?).to be(false)
    end

    specify 'pre-loads otus when you tell it to' do
      otu = FactoryBot.create(:valid_otu)

      lead.update!(otu_id: otu.id)

      q = Lead.roots_with_data(project_id, true)
      expect(q.first.association(:otu).loaded?).to be(true)
    end

  end

  context 'with multiple couplets' do
    before(:all) do
      Lead.delete_all
    end

    #       root
    #      /    \
    #     l      r
    #   / | \
    # ll lm  lr
    #       /  \
    #     lrl  lrr
    let!(:root) { FactoryBot.create(:valid_lead) }
    let!(:l) { root.children.create!(text: 'l') }
    let!(:r) { root.children.create!(text: 'r') }
    let!(:ll) { l.children.create!(text: 'll') }
    let!(:lm) { l.children.create!(text: 'lm') }
    let!(:lr) { l.children.create!(text: 'lr') }
    let!(:lrl) { lr.children.create!(text: 'lrl') }
    let!(:lrr) { lr.children.create!(text: 'lrr') }
    let!(:lead_all_size) { 8 }

    specify 'future honors redirect' do
      expect(r.future.size).to be(0)
      r.redirect_id = lr.id
      expect(r.future.size).to be(2)
      expect(r.future.first[:lead].text).to eq('lrr')
    end

    specify 'dupe' do
      title = root.text
      expect(Lead.all.size).to eq(lead_all_size)

      expect(root.dupe).to eq true

      expect(Lead.all.size).to eq(2 * lead_all_size)
      expect(Lead.where('parent_id is null').size).to eq(2)
      expect(Lead.where('parent_id is null').order(:id)[1].text)
        .to eq('(COPY OF) ' + title)
    end

    context '#swap' do
      specify '#swap left return data' do
        swap_result = lm.swap('L')
        lm.reload
        ll.reload
        expect(swap_result[:positions]).to eq [lm.position, ll.position]
        expect(swap_result[:leads]).to eq [lm, ll]
      end

      specify '#swap left db result' do
        lm.swap('L')
        l.reload
        expect(l.children[0].text).to eq 'lm'
        expect(l.children[1].text).to eq 'll'
        expect(l.children[2].text).to eq 'lr'
      end

      specify '#swap right return data' do
        swap_result = ll.swap('R')
        ll.reload
        lm.reload
        expect(swap_result[:positions]).to eq [ll.position, lm.position]
        expect(swap_result[:leads]).to eq [ll, lm]
      end

      specify '#swap right db result' do
        ll.swap('R')
        l.reload
        expect(l.children[0].text).to eq 'lm'
        expect(l.children[1].text).to eq 'll'
        expect(l.children[2].text).to eq 'lr'
      end

      specify "#swap moves children's descendants with children" do
        lm.swap('R')
        l.reload
        # lr's children went with lr
        expect(l.children[1].children.count).to eq 2
        expect(l.children[2].children.count).to eq 0
      end
    end

    context '#insert_key' do
      let(:other_key) {
        a = FactoryBot.create(:valid_lead, text: 'other key')
        a.children.create!(text: 'other left')
        a.children.create!(text: 'other right')
        a
      }
      let(:other_key_size) { 3 }

      before(:each) do
        l.insert_key(other_key.id)
      end

      specify 'creates expected number of leads' do
        expect(Lead.all.size)
          # We've added (other_key) + (dup of other_key)
          .to eq(lead_all_size + other_key_size + other_key_size)
      end

      specify 'appends copied root in the right place' do
        l.reload
        # l originally had 3 children
        expect(l.children.count).to eq(3 + 1)
        # This also tests that insert_key replaces '(COPY OF) ', which was
        # added during duping, with '(INSERTED KEY)'.
        expect(l.children[-1].text).to eq('(INSERTED KEY) other key')
      end
    end

    specify 'all_children' do
      expect(root.all_children.size).to eq(lead_all_size - 1)
      expect(root.all_children.first[:lead].text).to eq('r')
      expect(root.all_children.last[:lead].text).to eq('l')
      expect(l.all_children.size).to eq(5)
      expect(r.all_children.size).to eq(0)
    end

    specify 'all_children_standard_key' do
      expect(root.all_children_standard_key.size).to eq(lead_all_size - 1)
      expect(root.all_children_standard_key.first[:lead].text).to eq('l')
      expect(root.all_children_standard_key.last[:lead].text).to eq('lrr')
      expect(l.all_children_standard_key.size).to eq(5)
      expect(r.all_children_standard_key.size).to eq(0)
    end

    specify 'current positions are correct after #insert_couplet (left)' do
      l.insert_couplet
      # Position shouldn't change L or R
      expect(Lead.find_by(text: 'l').position)
        .to be < Lead.find_by(text: 'r').position
    end

    specify 'inserted lead positions are correct after #insert_couplet (left)' do
      ids = l.insert_couplet
      # Children should be left/right OK
      expect(Lead.find(ids[0]).position).to be < Lead.find(ids[1]).position
    end

    specify 're-attached child lead positions are correct after #insert_couplet (left)' do
      l.insert_couplet
      # Grand children maintain position
      expect(Lead.find_by(text: 'll').position)
        .to be < Lead.find_by(text: 'lr').position
    end

    specify 'current positions are correct after #insert_couplet (right)' do
      lr.insert_couplet
      # Position shouldn't change L or R
      expect(Lead.find_by(text: 'll').position)
        .to be < Lead.find_by(text: 'lr').position
    end

    specify 'inserted lead positions are correct after #insert_couplet (right)' do
      ids = lr.insert_couplet
      # Children should be left/right OK
      expect(Lead.find(ids[0]).position)
        .to be < Lead.find(ids[1]).position
    end

    specify 're-attached child lead positions are correct after #insert_couplet (right)' do
      lr.insert_couplet
      # Grand children maintain position
      expect(Lead.find_by(text: 'lrl').position)
        .to be < Lead.find_by(text: 'lrr').position
    end

    specify 'insert_couplet reparents on the right if self was a right child' do
      # lr is a right child, so reparented children should be on right.
      ids = lr.insert_couplet

      expect(Lead.find(ids[0]).children.size).to eq(0)
      expect(Lead.find(ids[1]).all_children.size).to eq(2)

      expect(Lead.find(ids[0]).text).to eq('Inserted node')
      expect(Lead.find(ids[1]).text).to eq('Child nodes are attached to this node')
    end

    specify 'insert_couplet reparents on the left if self was a left child' do
      # l is a left child, so reparented children should be on left.
      ids = l.insert_couplet

      expect(Lead.find(ids[0]).all_children.size).to eq(5)
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

    context '#transaction_nuke' do
      specify 'nukes' do
        second_key = FactoryBot.create(:valid_lead)
        second_key.insert_couplet

        expect(Lead.all.size).to eq(lead_all_size + 3)

        expect(root.transaction_nuke).to be_truthy
        expect(Lead.all.reload.size).to eq(3)
        expect(Lead.find(second_key.id)).to eq(second_key)
      end

      specify 'destroys all children of a key' do
        second_key = FactoryBot.create(:valid_lead)
        second_key.insert_couplet

        expect(Lead.all.size).to eq(lead_all_size + 3)
        expect(root.nuke).to be_truthy
        expect(Lead.all.reload.size).to eq(3)
      end

      specify 'leaves other keys alone' do
        second_key = FactoryBot.create(:valid_lead)
        second_key.insert_couplet
        root.nuke
        expect(Lead.all.reload.size).to eq(3)
        expect(Lead.find(second_key.id)).to eq(second_key)
      end

      specify 'can be applied to just a subtree' do
        lr.transaction_nuke
        expect(Lead.all.size).to eq(lead_all_size - 3)
        expect(l.reload.children.map(&:text)).to contain_exactly('ll', 'lm')
      end
    end

    specify 'destroy_children noops when both children have children' do
      r.children.create!(text: 'rl')
      r.children.create!(text: 'rr')
      expect(Lead.where('parent_id is null').first.destroy_children).to be(false)
      expect(Lead.where('parent_id is null').first.all_children.size)
        .to be(lead_all_size - 1 + 2)
    end

    specify 'destroy_children noops on a couplet with no children' do
      expect(Lead.find_by(text: 'r').destroy_children).to be(true)
      expect(Lead.where('parent_id is null').first.all_children.size)
        .to be(lead_all_size - 1)
    end

    specify "destroy_children doesn't change order of parent node pair (left)" do
      l.destroy_children
      expect(Lead.find_by(text: 'l').position)
        .to be < Lead.find_by(text: 'r').position
    end

    specify "destroy_children doesn't change order of reparented nodes (left)" do
      l.destroy_children
      expect(Lead.find_by(text: 'lrl').position)
        .to be < Lead.find_by(text: 'lrr').position
    end

    specify "destroy_children doesn't change order of parent node pair (right)" do
      rl = r.children.create!(text: 'rl')
      r.children.create!(text: 'rr')
      rl.children.create!(text: 'rll')
      rl.children.create!(text: 'rlr')

      r.reload.destroy_children
      expect(Lead.find_by(text: 'l').position)
        .to be < Lead.find_by(text: 'r').position
    end

    specify "destroy_children doesn't change order of reparented nodes (right)" do
      rl = r.children.create!(text: 'rl')
      r.children.create!(text:'rr')
      rl.children.create!(text: 'rll')
      rl.children.create!(text: 'rlr')

      r.reload.destroy_children
      expect(Lead.find_by(text: 'rll').position)
        .to be < Lead.find_by(text: 'rlr').position
    end

    specify "destroy_children doesn't change order of 3 reparented nodes (left)" do
      lrm = FactoryBot.create(:valid_lead, text: 'middle child of lr')
      lrl.append_sibling(lrm)

      l.reload.destroy_children

      expect(Lead.find_by(text: 'lrl').position)
        .to be < Lead.find_by(text: 'middle child of lr').position
      expect(Lead.find_by(text: 'middle child of lr').position)
        .to be < Lead.find_by(text: 'lrr').position
    end

    specify '#all_children' do
      lrl.children.create!(text: 'lrll')
      lrl.children.create!(text: 'lrlr')
      # 2 new leads below l, 3 leads above l
      expect(l.all_children.size).to eq(lead_all_size + 2 - 3)
    end

    specify '#destroy_children yields expected parent/child relationships' do
      # Test with grandchildren of l.
      lrll = lrl.children.create!(text: 'lrll')
      lrlr = lrl.children.create!(text: 'lrlr')

      expect(l.destroy_children).to be(true)
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
