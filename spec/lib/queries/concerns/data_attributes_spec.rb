require 'rails_helper'

describe Queries::Concerns::DataAttributes, type: :model, group: [:filter] do

  # Use CO by proxy
  let(:query) { Queries::CollectionObject::Filter.new({}) }

  let(:p1) { FactoryBot.create(:valid_predicate) }
  let(:p2) { FactoryBot.create(:valid_predicate) }

  specify '#data_attributes' do
    d = InternalAttribute.create!(predicate: p1, value: 1, attribute_subject: Specimen.create!)
    Specimen.create!

    query.data_attributes = true
    expect(query.all.pluck(:id)).to contain_exactly(d.attribute_subject.id)
  end

  specify '#data_attribute_without_predicate_id' do
    n = Specimen.create!
    s = Specimen.create!
    FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: s)

    query.data_attribute_without_predicate_id = s.data_attributes.first.controlled_vocabulary_term_id
    expect(query.all).to contain_exactly(n)
  end

  specify '#data_attribute_predicate_id' do
    n = Specimen.create!
    s = Specimen.create!
    FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: s)

    query.data_attribute_predicate_id = s.data_attributes.first.controlled_vocabulary_term_id
    expect(query.all).to contain_exactly(s)
  end

  specify '#data_attribute_exact_value' do
    d = InternalAttribute.create!(predicate: p1, value: 1, attribute_subject: Specimen.create!)
    Specimen.create!

    query.data_attribute_exact_value = 1
    expect(query.all).to contain_exactly(d.attribute_subject)
  end

  specify '#data_attribute_wildcard_value 1' do
    d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
    Specimen.create!

    query.data_attribute_wildcard_value = 1
    expect(query.all).to contain_exactly(d.attribute_subject)
  end

  specify '#data_attribute_exact_pair 1' do
    d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
    Specimen.create!

    query.data_attribute_exact_pair = {p1.id => '212'}
    expect(query.all).to contain_exactly(d.attribute_subject)
  end

  specify '#data_attribute_wildcard_pair 1' do
    d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
    Specimen.create!

    query.data_attribute_wildcard_pair = {p1.id => '2'}
    expect(query.all).to contain_exactly(d.attribute_subject)
  end

end
