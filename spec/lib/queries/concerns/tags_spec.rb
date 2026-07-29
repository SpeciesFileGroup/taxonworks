require 'rails_helper'

describe Queries::Concerns::Tags, type: :model, group: [:filter] do

  # Vehicle - any filter that includes Queries::Concerns::Tags; Source is
  # used here as it does not also include Queries::Concerns::Confidences.
  let(:query) { Queries::Source::Filter.new({}) }

  let!(:s1) { FactoryBot.create(:valid_source) }
  let!(:s2) { FactoryBot.create(:valid_source) }
  let!(:s3) { FactoryBot.create(:valid_source) }

  let!(:all_source_ids) { [s1.id, s2.id, s3.id] }

  specify '#with_tag 1' do
    Tag.create!(keyword: FactoryBot.create(:valid_keyword), tag_object: s1)
    query.tags = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  specify '#with_tag 1 (distinct)' do
    Tag.create!(keyword: FactoryBot.create(:valid_keyword), tag_object: s1)
    Tag.create!(keyword: FactoryBot.create(:valid_keyword), tag_object: s1)
    query.tags = true
    expect(query.all.map(&:id)).to contain_exactly(s1.id)
  end

  context 'keyword_id' do
    specify '#keyword_id_and' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_and = [t1.keyword_id, t2.keyword_id]
      expect(query.matching_keyword_id_and.map(&:id)).to contain_exactly(s1.id)
    end

    specify '#keyword_id_or' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_or = [t1.keyword_id, t2.keyword_id]
      expect(query.matching_keyword_id_or.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

    specify '#keyword_id_or, #keyword_id_and 1' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))

      t3 = Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword))

      # not this
      t4 = Tag.create!(tag_object: s3, keyword: t1.keyword)

      query.keyword_id_and = [t1.keyword_id, t2.keyword_id]
      query.keyword_id_or = [t3.keyword_id]

      expect(query.all.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

    specify '#keyword_id_or, #keyword_id_and 2 (one AND is an OR)' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))
      t2 = Tag.create!(tag_object: s2, keyword: FactoryBot.create(:valid_keyword))

      # not this
      t3 = Tag.create!(tag_object: s3, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_and = [t1.keyword_id]
      query.keyword_id_or = [t2.keyword_id]

      expect(query.all.map(&:id)).to contain_exactly(s1.id, s2.id)
    end

    specify '#exclude_tags' do
      t1 = Tag.create!(tag_object: s1, keyword: FactoryBot.create(:valid_keyword))

      query.keyword_id_or = [t1.keyword_id]
      query.exclude_tags = true

      expect(query.all.map(&:id)).to contain_exactly(*(all_source_ids - [s1.id]))
    end

    # This requires De Morgan's law to combine correctly:
    #   NOT (or_match OR and_match) == (NOT or_match) AND (NOT and_match)
    # keyword_id_facet already unions or_match and and_match into one result
    # before negate_facet wraps it, which is the correct order. A broken
    # implementation that instead negated the OR-list and AND-list matches
    # independently and then *unioned* those negated pieces together (rather
    # than intersecting, or rather than negating the pre-unioned whole) would
    # compute (NOT or_match) OR (NOT and_match) instead - which disagrees
    # with the correct result exactly on objects that satisfy only one side.
    context '#exclude_tags with both keyword_id_or and keyword_id_and set' do
      let!(:k1) { FactoryBot.create(:valid_keyword) }
      let!(:k2) { FactoryBot.create(:valid_keyword) }
      let!(:k3) { FactoryBot.create(:valid_keyword) }

      let!(:s_or_only) { FactoryBot.create(:valid_source) }
      let!(:s_and_only) { FactoryBot.create(:valid_source) }
      let!(:s_both) { FactoryBot.create(:valid_source) }
      let!(:s_neither) { FactoryBot.create(:valid_source) }

      before do
        Tag.create!(tag_object: s_or_only, keyword: k1) # matches OR-list only

        Tag.create!(tag_object: s_and_only, keyword: k2) # matches AND-list only
        Tag.create!(tag_object: s_and_only, keyword: k3)

        Tag.create!(tag_object: s_both, keyword: k1) # matches both
        Tag.create!(tag_object: s_both, keyword: k2)
        Tag.create!(tag_object: s_both, keyword: k3)
        # s_neither gets no tags

        query.keyword_id_or = [k1.id]
        query.keyword_id_and = [k2.id, k3.id]
      end

      specify 'combined OR/AND, not excluded' do
        # sanity check of the base (non-negated) combination: or_match OR and_match
        expect(query.all.map(&:id)).to contain_exactly(s_or_only.id, s_and_only.id, s_both.id)
      end

      specify 'combined OR/AND, excluded' do
        query.exclude_tags = true

        # correct complement: NOT or_match AND NOT and_match - drops s_or_only
        # and s_and_only (each satisfies exactly one side), which a broken
        # union-of-negated-pieces implementation would wrongly keep
        expect(query.all.map(&:id)).to contain_exactly(*(all_source_ids + [s_neither.id]))
      end
    end

  end

end
