require 'rails_helper'

describe Queries::AssertedEnvironment::Sort, type: :model, group: [:filter] do
  let!(:ae_b) { FactoryBot.create(:valid_asserted_environment, uri_label: 'beta soil') }
  let!(:ae_a) { FactoryBot.create(:valid_asserted_environment, uri_label: 'alpha water') }

  let(:set) { Queries::AssertedEnvironment::Filter.new(asserted_environment_id: [ae_a.id, ae_b.id]).all }

  specify 'keys are the table columns, with object_type for the object type column' do
    expect(described_class.keys).to include('uri_label', 'uri', 'object_type', 'updated_at')
  end

  specify 'sort=uri_label orders by the ENVO term' do
    expect(Queries::Pager.new(set, sort: 'uri_label').all.map(&:id)).to eq([ae_a.id, ae_b.id])
    expect(Queries::Pager.new(set, sort: '-uri_label').all.map(&:id)).to eq([ae_b.id, ae_a.id])
  end

  specify 'recent orders most recently updated first' do
    ae_a.update_column(:updated_at, 2.days.ago)
    ae_b.update_column(:updated_at, 1.day.ago)
    expect(Queries::Pager.new(set, recent: 'true').all.map(&:id)).to eq([ae_b.id, ae_a.id])
  end
end
