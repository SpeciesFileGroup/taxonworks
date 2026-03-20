require 'rails_helper'

RSpec.describe LeadsHelper, type: :helper do
  specify 'key_metadata numbers couplets depth-first' do
    root = FactoryBot.create(:valid_lead, text: 'root')
    l = root.children.create!(text: 'l')
    l.children.create!(text: 'll')
    lr = l.children.create!(text: 'lr')
    lr.children.create!(text: 'lrl')
    lr.children.create!(text: 'lrr')
    root.children.create!(text: 'm')
    r = root.children.create!(text: 'r')
    r.children.create!(text: 'rl')
    r.children.create!(text: 'rr')

    meta = helper.key_metadata(root)

    expect(meta[root.id][:couplet_number]).to eq(1)
    expect(meta[l.id][:couplet_number]).to eq(2)
    expect(meta[lr.id][:couplet_number]).to eq(3)
    expect(meta[r.id][:couplet_number]).to eq(4)
  end

  specify 'key_data includes redirect_id for redirect leads' do
    root = FactoryBot.create(:valid_lead, text: 'root')
    target = root.children.create!(text: 'target')
    target.children.create!(text: 'target left')
    target.children.create!(text: 'target right')
    redirect_lead = root.children.create!(text: 'go to target', redirect_id: target.id)

    meta = helper.key_metadata(root)
    data = helper.key_data(root, meta)

    expect(data[redirect_lead.id][:redirect_id]).to eq(target.id)
    expect(data[redirect_lead.id][:target_type]).to eq(:redirect)
  end
end
