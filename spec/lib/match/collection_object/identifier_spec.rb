require 'rails_helper'

describe Match::CollectionObject::Identifier, type: :model do

  let(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'INHS', delimiter: ':') }
  let(:co) { FactoryBot.create(:valid_collection_object) }
  let!(:identifier) { Identifier::Local::CatalogNumber.create!(namespace:, identifier: '123', identifier_object: co) }

  def match(identifiers, project_id: Current.project_id)
    described_class.new(identifiers:, project_id:).call
  end

  specify 'matched' do
    expect(match(['INHS:123']).first).to eq(
      identifier: 'INHS:123', collection_object_id: co.id, collection_object_ids: [co.id], ambiguous: false, matched: true
    )
  end

  specify 'not matched' do
    expect(match(['INHS:999']).first).to eq(
      identifier: 'INHS:999', collection_object_id: nil, collection_object_ids: [], ambiguous: false, matched: false
    )
  end

  specify 'matches cached exactly' do
    expect(match(['inhs:123', 'INHS 123']).map { |r| r[:matched] }).to eq([false, false])
  end

  specify 'ambiguous' do
    other = FactoryBot.create(:valid_collection_object)
    other_namespace = FactoryBot.create(:valid_namespace, verbatim_short_name: 'INHS', delimiter: ':')
    Identifier::Local::CatalogNumber.create!(namespace: other_namespace, identifier: '123', identifier_object: other)

    expect(match(['INHS:123']).first).to include(
      collection_object_id: nil, collection_object_ids: contain_exactly(co.id, other.id), ambiguous: true, matched: true
    )
  end

  specify 'identifiers on other objects are ignored' do
    Identifier::Local::CatalogNumber.create!(namespace:, identifier: '5', identifier_object: FactoryBot.create(:valid_container))
    expect(match(['INHS:5']).first[:matched]).to be_falsey
  end

  specify 'identifiers in other projects are ignored' do
    expect(match(['INHS:123'], project_id: Current.project_id + 1).first[:matched]).to be_falsey
  end

  specify 'one result per unique identifier, in order' do
    expect(match(['INHS:999', 'INHS:123', 'INHS:999']).map { |r| r[:identifier] }).to eq(['INHS:999', 'INHS:123'])
  end

  specify 'uses a single query regardless of the number of identifiers' do
    identifiers = (1..50).map { |n| "INHS:#{n}" }
    queries = []
    callback = ->(*, payload) { queries << payload[:sql] unless payload[:name] == 'SCHEMA' }

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      match(identifiers)
    end

    expect(queries.size).to eq(1)
  end

  specify 'no query without identifiers' do
    queries = []
    callback = ->(*, payload) { queries << payload[:sql] unless payload[:name] == 'SCHEMA' }

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      expect(match([])).to eq([])
    end

    expect(queries).to be_empty
  end

end
