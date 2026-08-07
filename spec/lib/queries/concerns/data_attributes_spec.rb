require 'rails_helper'

describe Queries::Concerns::DataAttributes, type: :model, group: [:filter] do

  # Use CO by proxy
  let(:query) { Queries::CollectionObject::Filter.new({}) }

  let(:p1) { FactoryBot.create(:valid_predicate) }
  let(:p2) { FactoryBot.create(:valid_predicate) }

  context '#data_attribute_facet with value_type :exact' do
    let(:s1) { Specimen.create! }
    let(:s2) { Specimen.create! }
    let(:s3) { Specimen.create! }

    context 'with specific predicate_id (id > 0)' do
      context 'negator = false' do
        specify 'returns specimens with exact predicate and value match' do
          InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to contain_exactly(s1)
        end

        specify 'does not match when value differs' do
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s1)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to be_empty
        end

        specify 'does not match when predicate differs' do
          InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s1)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to be_empty
        end
      end

      context 'negator = true' do
        specify 'returns specimens with predicate where value differs' do
          InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to contain_exactly(s2)
        end

        specify 'does not return specimens without the predicate' do
          InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s1)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to contain_exactly(s2)
        end
      end
    end

    context 'with any predicate (id = 0)' do
      context 'negator = false' do
        specify 'returns specimens with exact value match on any predicate' do
          InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s2)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s3)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to contain_exactly(s1, s2)
        end

        specify 'does not match when no value matches' do
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s1)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to be_empty
        end
      end

      context 'negator = true' do
        specify 'returns specimens with any data attribute where value differs' do
          InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to contain_exactly(s2)
        end

        specify 'does not return specimens without data attributes' do
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s1)
          # s2, s3 have no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['exact']
          )

          expect(query.all).to contain_exactly(s1)
        end
      end
    end
  end

  context '#data_attribute_facet with value_type :wildcard' do
    let(:s1) { Specimen.create! }
    let(:s2) { Specimen.create! }
    let(:s3) { Specimen.create! }

    context 'with specific predicate_id (id > 0)' do
      context 'negator = false' do
        specify 'returns specimens with predicate and partial value match' do
          InternalAttribute.create!(predicate: p1, value: 'dark green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s2)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s3)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to contain_exactly(s1)
        end

        specify 'does not match when value not contained' do
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s1)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to be_empty
        end
      end

      context 'negator = true' do
        specify 'returns specimens with predicate where value does not contain match' do
          InternalAttribute.create!(predicate: p1, value: 'dark green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to contain_exactly(s2)
        end

        specify 'does not return specimens without the predicate' do
          InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s1)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [p1.id],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to contain_exactly(s2)
        end
      end
    end

    context 'with any predicate (id = 0)' do
      context 'negator = false' do
        specify 'returns specimens with partial value match on any predicate' do
          InternalAttribute.create!(predicate: p1, value: 'dark green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p2, value: 'greenish', attribute_subject: s2)
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s3)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to contain_exactly(s1, s2)
        end

        specify 'does not match when no value contains match' do
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s1)

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [false],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to be_empty
        end
      end

      context 'negator = true' do
        specify 'returns specimens with any data attribute where value does not contain match' do
          InternalAttribute.create!(predicate: p1, value: 'dark green', attribute_subject: s1)
          InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s2)
          # s3 has no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to contain_exactly(s2)
        end

        specify 'does not return specimens without data attributes' do
          InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s1)
          # s2, s3 have no data attributes

          query.set_data_attributes_params(
            data_attribute_predicate_row_id: [0],
            data_attribute_value: ['green'],
            data_attribute_value_negator: [true],
            data_attribute_value_type: ['wildcard']
          )

          expect(query.all).to contain_exactly(s1)
        end
      end
    end
  end

  context '#data_attribute_facet with value_type :any' do
    let(:s1) { Specimen.create! }
    let(:s2) { Specimen.create! }
    let(:s3) { Specimen.create! }

    context 'with specific predicate_id (id > 0)' do
      specify 'returns specimens with predicate present' do
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s2)
        # s3 has no data attributes

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id],
          data_attribute_value: ['ignored'],
          data_attribute_value_negator: [false],
          data_attribute_value_type: ['any']
        )

        expect(query.all).to contain_exactly(s1)
      end

      specify 'returns specimens without the predicate when negated' do
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s2)
        # s3 has no data attributes

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id],
          data_attribute_value: ['ignored'],
          data_attribute_value_negator: [true],
          data_attribute_value_type: ['any']
        )

        expect(query.all).to contain_exactly(s2, s3)
      end
    end

    context 'with any predicate (id = 0)' do
      specify 'returns specimens with any predicate' do
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s2)
        # s3 has no data attributes

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [0],
          data_attribute_value: ['ignored'],
          data_attribute_value_negator: [false],
          data_attribute_value_type: ['any']
        )

        expect(query.all).to contain_exactly(s1, s2)
      end

      specify 'returns specimens with no predicates when negated' do
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s2)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [0],
          data_attribute_value: ['ignored'],
          data_attribute_value_negator: [true],
          data_attribute_value_type: ['any']
        )

        expect(query.all).to contain_exactly(s3)
      end
    end
  end

  context '#data_attribute_facet with value_type :no' do
    let(:s1) { Specimen.create! }
    let(:s2) { Specimen.create! }
    let(:s3) { Specimen.create! }

    context 'with specific predicate_id (id > 0)' do
      specify 'returns specimens without the predicate' do
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s2)
        # s3 has no data attributes

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id],
          data_attribute_value: ['ignored'],
          data_attribute_value_negator: [false],
          data_attribute_value_type: ['no']
        )

        expect(query.all).to contain_exactly(s2, s3)
      end

      specify 'returns specimens with the predicate when negated' do
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'blue', attribute_subject: s2)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id],
          data_attribute_value: ['ignored'],
          data_attribute_value_negator: [true],
          data_attribute_value_type: ['no']
        )

        expect(query.all).to contain_exactly(s1)
      end
    end
  end

  context '#data_attribute_facet with combine_logic' do
    let(:s1) { Specimen.create! }
    let(:s2) { Specimen.create! }
    let(:s3) { Specimen.create! }
    let(:s4) { Specimen.create! }

    # p1 = Color, p2 = Size
    context 'AND (combine_logic: nil)' do
      specify 'returns specimens matching both conditions' do
        # s1: Color=green, Size=large
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s1)
        # s2: Color=green only
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s2)
        # s3: Size=large only
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s3)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p2.id],
          data_attribute_value: ['green', 'large'],
          data_attribute_value_negator: [false, false],
          data_attribute_value_type: ['exact', 'exact'],
          data_attribute_combine_logic: [nil, nil]
        )

        expect(query.all).to contain_exactly(s1)
      end
    end

    context 'OR (combine_logic: true)' do
      specify 'returns specimens matching either condition' do
        # s1: Color=green
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        # s2: Color=blue
        InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)
        # s3: Color=red
        InternalAttribute.create!(predicate: p1, value: 'red', attribute_subject: s3)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p1.id],
          data_attribute_value: ['green', 'blue'],
          data_attribute_value_negator: [false, false],
          data_attribute_value_type: ['exact', 'exact'],
          data_attribute_combine_logic: [true, nil]
        )

        expect(query.all).to contain_exactly(s1, s2)
      end
    end

    context 'AND NOT (combine_logic: false)' do
      specify 'returns specimens matching first but not second condition' do
        # s1: Color=green, Size=large
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s1)
        # s2: Color=green, Size=small
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s2)
        InternalAttribute.create!(predicate: p2, value: 'small', attribute_subject: s2)
        # s3: Color=green only (no size)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s3)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p2.id],
          data_attribute_value: ['green', 'small'],
          data_attribute_value_negator: [false, false],
          data_attribute_value_type: ['exact', 'exact'],
          data_attribute_combine_logic: [false, nil]
        )

        expect(query.all).to contain_exactly(s1, s3)
      end
    end

    context 'chained logic' do
      specify 'Color=green AND Size=large OR Weight=heavy' do
        # s1: green, large
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s1)
        # s2: green, small (no match)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s2)
        InternalAttribute.create!(predicate: p2, value: 'small', attribute_subject: s2)
        # s3: blue, heavy (matches via OR)
        InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s3)
        InternalAttribute.create!(predicate: p2, value: 'heavy', attribute_subject: s3)

        p3 = FactoryBot.create(:valid_predicate) # Weight

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p2.id, p2.id],
          data_attribute_value: ['green', 'large', 'heavy'],
          data_attribute_value_negator: [false, false, false],
          data_attribute_value_type: ['exact', 'exact', 'exact'],
          data_attribute_combine_logic: [nil, true, nil]  # AND, then OR
        )

        expect(query.all).to contain_exactly(s1, s3)
      end

      specify 'Color=green OR Size=large AND Weight=heavy (left-to-right)' do
        # Note: precedence is left-to-right, not SQL's OR/AND precedence.
        # SQL precedence would also include s3 (green only) via r1 OR (r2 AND r3).
        # s1: green, heavy (matches)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        p3 = FactoryBot.create(:valid_predicate) # Weight
        InternalAttribute.create!(predicate: p3, value: 'heavy', attribute_subject: s1)
        # s2: large, heavy (matches)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s2)
        InternalAttribute.create!(predicate: p3, value: 'heavy', attribute_subject: s2)
        # s3: green only (would match if OR took precedence)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s3)
        # s4: large only (no match)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s4)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p2.id, p3.id],
          data_attribute_value: ['green', 'large', 'heavy'],
          data_attribute_value_negator: [false, false, false],
          data_attribute_value_type: ['exact', 'exact', 'exact'],
          data_attribute_combine_logic: [true, nil, nil]  # OR, then AND
        )

        expect(query.all).to contain_exactly(s1, s2)
      end

      specify 'Color:any OR Size:exact AND NOT Weight:no (left-to-right)' do
        p3 = FactoryBot.create(:valid_predicate) # Weight
        # s1: Color present, Weight present (matches via r1)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
        InternalAttribute.create!(predicate: p3, value: 'heavy', attribute_subject: s1)
        # s2: Size=large, Weight present (matches via r2 AND NOT r3)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s2)
        InternalAttribute.create!(predicate: p3, value: 'heavy', attribute_subject: s2)
        # s3: Size=large, no Weight (fails NOT r3)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s3)
        # s4: no attributes (no match)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p2.id, p3.id],
          data_attribute_value: ['ignored', 'large', 'ignored'],
          data_attribute_value_negator: [false, false, false],
          data_attribute_value_type: ['any', 'exact', 'no'],
          data_attribute_combine_logic: [true, false, nil] # OR, then AND NOT
        )

        expect(query.all).to contain_exactly(s1, s2)
      end

      specify 'Color:no OR Size:any AND Weight:any (left-to-right)' do
        p3 = FactoryBot.create(:valid_predicate) # Weight
        # s1: no Color, Size+Weight present (matches r1 OR (r2 AND r3) in LTR)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s1)
        InternalAttribute.create!(predicate: p3, value: 'heavy', attribute_subject: s1)
        # s2: no Color, Size only (fails r2 AND r3)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s2)
        # s3: Color present, Size+Weight present (matches via r2 AND r3)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s3)
        InternalAttribute.create!(predicate: p2, value: 'large', attribute_subject: s3)
        InternalAttribute.create!(predicate: p3, value: 'heavy', attribute_subject: s3)
        # s4: Color present only (no match)
        InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s4)

        query.set_data_attributes_params(
          data_attribute_predicate_row_id: [p1.id, p2.id, p3.id],
          data_attribute_value: ['ignored', 'ignored', 'ignored'],
          data_attribute_value_negator: [false, false, false],
          data_attribute_value_type: ['no', 'any', 'any'],
          data_attribute_combine_logic: [true, nil, nil] # OR, then AND
        )

        expect(query.all).to contain_exactly(s1, s3)
      end
    end
  end

  context 'row-based data attributes' do
    let(:s1) { Specimen.create! }
    let(:s2) { Specimen.create! }
    let(:s3) { Specimen.create! }

    specify 'exact match with predicate' do
      InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
      InternalAttribute.create!(predicate: p2, value: 'green', attribute_subject: s2)

      query.set_data_attributes_params(
        data_attribute_predicate_row_id: [p1.id],
        data_attribute_value: ['green'],
        data_attribute_value_negator: [false],
        data_attribute_value_type: ['exact'],
        data_attribute_combine_logic: [nil]
      )

      expect(query.all).to contain_exactly(s1)
    end

    specify 'wildcard match with any predicate' do
      InternalAttribute.create!(predicate: p1, value: 'dark green', attribute_subject: s1)
      InternalAttribute.create!(predicate: p2, value: 'greenish', attribute_subject: s2)
      InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s3)

      query.set_data_attributes_params(
        data_attribute_predicate_row_id: [0],
        data_attribute_value: ['green'],
        data_attribute_value_negator: [false],
        data_attribute_value_type: ['wildcard'],
        data_attribute_combine_logic: [nil]
      )

      expect(query.all).to contain_exactly(s1, s2)
    end

    specify 'any/no value types' do
      InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
      InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)

      query.set_data_attributes_params(
        data_attribute_predicate_row_id: [p1.id],
        data_attribute_value: ['ignored'],
        data_attribute_value_negator: [false],
        data_attribute_value_type: ['no'],
        data_attribute_combine_logic: [nil]
      )

      expect(query.all).to contain_exactly(s3)
    end

    specify 'combine logic OR' do
      InternalAttribute.create!(predicate: p1, value: 'green', attribute_subject: s1)
      InternalAttribute.create!(predicate: p1, value: 'blue', attribute_subject: s2)

      query.set_data_attributes_params(
        data_attribute_predicate_row_id: [p1.id, p1.id],
        data_attribute_value: ['green', 'blue'],
        data_attribute_value_negator: [false, false],
        data_attribute_value_type: ['exact', 'exact'],
        data_attribute_combine_logic: [true]
      )

      expect(query.all).to contain_exactly(s1, s2)
    end
  end

  context 'legacy predicate filter (API only)' do
    specify '#data_attribute_predicate_id' do
      n = Specimen.create!
      s = Specimen.create!
      FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: s)

      query.data_attribute_predicate_id = s.data_attributes.first.controlled_vocabulary_term_id
      expect(query.all).to contain_exactly(s)
    end
  end

  context 'legacy API-only params' do
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

    specify '#data_attribute_exact_value' do
      d = InternalAttribute.create!(predicate: p1, value: 1, attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_exact_value = 1
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_wildcard_value' do
      d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_wildcard_value = 1
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_exact_pair' do
      d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_exact_pair = { p1.id => '212' }
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_wildcard_pair' do
      d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_wildcard_pair = { p1.id => '2' }
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_wildcard_pair and #data_attribute_exact_pair are anded' do
      d = InternalAttribute.create!(predicate: p1, value: '212', attribute_subject: Specimen.create!)
      e = InternalAttribute.create!(predicate: p1, value: '313', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_wildcard_pair = ["#{p1.id}:21", "#{p1.id}:31"]
      query.data_attribute_exact_pair = { p1.id => '313' }

      expect(query.all).to contain_exactly(e.attribute_subject)
    end
  end

  context 'legacy import params (API only)' do
    let(:import_predicate) { 'import:predicate' }

    specify '#data_attribute_import_predicate' do
      d = ImportAttribute.create!(import_predicate:, value: 'foo', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_import_predicate = [import_predicate]
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_import_exact_value' do
      d = ImportAttribute.create!(import_predicate:, value: 'foo', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_import_exact_value = ['foo']
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_import_wildcard_value' do
      d = ImportAttribute.create!(import_predicate:, value: 'foo bar', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_import_wildcard_value = ['foo']
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_import_exact_pair' do
      d = ImportAttribute.create!(import_predicate:, value: 'foo', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_import_exact_pair = { import_predicate => 'foo' }
      expect(query.all).to contain_exactly(d.attribute_subject)
    end

    specify '#data_attribute_import_wildcard_pair' do
      d = ImportAttribute.create!(import_predicate:, value: 'foo bar', attribute_subject: Specimen.create!)
      Specimen.create!

      query.data_attribute_import_wildcard_pair = { import_predicate => 'foo' }
      expect(query.all).to contain_exactly(d.attribute_subject)
    end
  end

end
