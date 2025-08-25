require 'rails_helper'

describe Vocabulary, type: :model do
  let!(:co1) { FactoryBot.create(
    :valid_collection_object, buffered_determinations: 'cataract', total: 3)
  }
  let!(:co2) { FactoryBot.create(
    :valid_collection_object, buffered_determinations: 'jaundice', total: 12)
  }
  let!(:co3) { FactoryBot.create(
    :valid_collection_object, buffered_determinations: 'jaundice', total: 3)
  }

  specify 'text field' do
    words = ::Vocabulary.words(
      model: 'CollectionObject', limit: 10,
      attribute: 'buffered_determinations',
      project_id: Current.project_id
    )

    expect(words).to eq({"jaundice" => 2, "cataract" => 1})
  end

  specify 'non-text field' do
    words = ::Vocabulary.words(
      model: 'CollectionObject', limit: 10,
      attribute: 'total',
      project_id: Current.project_id
    )

    expect(words).to eq({3 => 2, 12 => 1})
  end

  specify 'query' do
    words = ::Vocabulary.words(
      model: 'CollectionObject', limit: 10,
      attribute: 'buffered_determinations',
      project_id: Current.project_id,
      collection_object_query: { collection_object_id: [co1.id, co2.id]}
    )

    expect(words).to eq({"jaundice" => 1, "cataract" => 1})
  end

  specify 'min' do
    words = ::Vocabulary.words(
      model: 'CollectionObject', limit: 10,
      attribute: 'total',
      min: 1,
      project_id: Current.project_id
    )

    expect(words).to eq({3 => 2})
  end

  specify 'query begins_with' do
    words = ::Vocabulary.words(
      model: 'CollectionObject', limit: 10,
      attribute: 'buffered_determinations',
      project_id: Current.project_id,
      begins_with: 'jaun',
      collection_object_query: { collection_object_id: [co1.id, co2.id]}
    )

    expect(words).to eq({"jaundice" => 1})
  end
end