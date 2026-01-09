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

    specify '#data_attribute_exact_pair 2, multiple predicates with default (and)' do
    s1 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: s1)
    InternalAttribute.create!(predicate: p2, value: '313', attribute_subject: s1)

    s2 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: s2)

    Specimen.create!

    # Must use array form
    query.data_attribute_exact_pair = ["#{p1.id}:212", "#{p2.id}:313"]

    # With 'and' (default), only s1 has both predicates
    expect(query.all).to contain_exactly(s1)
  end

  specify '#data_attribute_exact_pair 3, multiple predicates are ored when data_attribute_between_and_or = or' do
    s1 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: s1)

    s2 = Specimen.create!
    InternalAttribute.create!(predicate: p2, value: '313', attribute_subject: s2)

    Specimen.create!

    # Must use array form
    query.data_attribute_exact_pair = ["#{p1.id}:212", "#{p2.id}:313"]
    query.data_attribute_between_and_or = 'or'

    expect(query.all).to contain_exactly(s1, s2)
  end

  specify '#data_attribute_wildcard_pair 1' do
    d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
    Specimen.create!

    query.data_attribute_wildcard_pair = {p1.id => '2'}
    expect(query.all).to contain_exactly(d.attribute_subject)
  end

  specify '#data_attribute_wildcard_pair 2, multiple predicates with default (and)' do
    s1 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: s1)
    InternalAttribute.create!(predicate: p2, value: '313', attribute_subject: s1)

    s2 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: s2)

    Specimen.create!

    # Must use array form
    query.data_attribute_wildcard_pair = ["#{p1.id}:21", "#{p2.id}:31"]

    # With 'and' (default), only s1 has both predicates
    expect(query.all).to contain_exactly(s1)
  end

  specify '#data_attribute_wildcard_pair 3, multiple predicates are ored when data_attribute_between_and_or = or' do
    s1 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: s1)

    s2 = Specimen.create!
    InternalAttribute.create!(predicate: p2, value: '313', attribute_subject: s2)

    Specimen.create!

    # Must use array form
    query.data_attribute_wildcard_pair = ["#{p1.id}:21", "#{p2.id}:31"]
    query.data_attribute_between_and_or = 'or'

    expect(query.all).to contain_exactly(s1, s2)
  end



  specify '#data_attribute_wildcard_pair and #data_attribute_exact_pair are anded (different facets)' do
    d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
    e = InternalAttribute.create!(predicate: p1, value: '313', attribute_subject: Specimen.create!)
    Specimen.create!

    # Must use array form
    query.data_attribute_wildcard_pair = ["#{p1.id}:21", "#{p1.id}:31"]
    query.data_attribute_exact_pair = {p1.id => '313' }
    query.data_attribute_between_and_or = 'or'

    # wildcard_pair matches both d and e, exact_pair matches only e
    # The two facets are AND'd together, so result is intersection = e only
    expect(query.all).to contain_exactly(e.attribute_subject)
  end

  specify '#data_attribute_wildcard_value with default (and)' do
    s1 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: 'abc def', attribute_subject: s1)

    s2 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: 'abc', attribute_subject: s2)

    query.data_attribute_wildcard_value = ['abc', 'def']

    # With 'and', only s1 has both values
    expect(query.all).to contain_exactly(s1)
  end

  specify '#data_attribute_wildcard_value with or' do
    s1 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: 'abc', attribute_subject: s1)

    s2 = Specimen.create!
    InternalAttribute.create!(predicate: p1, value: 'def', attribute_subject: s2)

    query.data_attribute_wildcard_value = ['abc', 'def']
    query.data_attribute_between_and_or = 'or'

    expect(query.all).to contain_exactly(s1, s2)
  end

  context 'import attributes' do
    specify '#data_attribute_import_exact_pair with default (and)' do
      s1 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'color', value: 'red', attribute_subject: s1)
      ImportAttribute.create!(import_predicate: 'size', value: 'large', attribute_subject: s1)

      s2 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'color', value: 'red', attribute_subject: s2)

      Specimen.create!

      query.data_attribute_import_exact_pair = ['color:red', 'size:large']

      # With 'and' (default), only s1 has both predicates
      expect(query.all).to contain_exactly(s1)
    end

    specify '#data_attribute_import_exact_pair with or' do
      s1 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'color', value: 'red', attribute_subject: s1)

      s2 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'size', value: 'large', attribute_subject: s2)

      Specimen.create!

      query.data_attribute_import_exact_pair = ['color:red', 'size:large']
      query.data_attribute_import_between_and_or = 'or'

      expect(query.all).to contain_exactly(s1, s2)
    end

    specify '#data_attribute_import_wildcard_value with default (and)' do
      s1 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'notes', value: 'abc def', attribute_subject: s1)

      s2 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'notes', value: 'abc', attribute_subject: s2)

      query.data_attribute_import_wildcard_value = ['abc', 'def']

      # With 'and', only s1 has both values
      expect(query.all).to contain_exactly(s1)
    end

    specify '#data_attribute_import_wildcard_value with or' do
      s1 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'notes', value: 'abc', attribute_subject: s1)

      s2 = Specimen.create!
      ImportAttribute.create!(import_predicate: 'notes', value: 'def', attribute_subject: s2)

      query.data_attribute_import_wildcard_value = ['abc', 'def']
      query.data_attribute_import_between_and_or = 'or'

      expect(query.all).to contain_exactly(s1, s2)
    end
  end

end
