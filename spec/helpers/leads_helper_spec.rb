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
end
