require 'rails_helper'

RSpec.describe Import, type: :model do
  it 'stores and retrieves string and symbol keys across reloads without losing other values' do
    record = Import.create!(name: 'JSON key regression', metadata_json: { 'run' => 1, 'other' => ['preserved'] })
    record.reload
    record.set(:run, 2)
    record.reload
    expect(record.get(:run)).to eq(2)
    expect(record.get('run')).to eq(2)
    expect(record.metadata_json).to eq({ 'run' => 2, 'other' => ['preserved'] })

    record.set('run', 3)
    expect(record.reload.get(:run)).to eq(3)
    record.set(:new_key, 'new value')
    expect(record.reload.get('new_key')).to eq('new value')
  end
end
