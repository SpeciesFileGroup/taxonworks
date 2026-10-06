require 'rails_helper'

describe Queries::Concerns::Confidences, type: :model, group: [:filter] do

  # Vehicle - any filter that includes Queries::Concerns::Confidences.
  let(:q) { Queries::Otu::Filter.new({}) }

  let(:o1) { Otu.create!(name: 'Abc 1') }
  let(:o2) { Otu.create!(name: 'Def 2') }

  specify '#confidence_level_id' do
    l = FactoryBot.create(:valid_confidence_level)
    c = FactoryBot.create(:valid_confidence, confidence_level: l, confidence_object: o1)
    q.confidence_level_id = l.id
    expect(q.all).to contain_exactly(o1)
  end

  specify '#without_confidence_level_id' do
    l = FactoryBot.create(:valid_confidence_level)
    c = FactoryBot.create(:valid_confidence, confidence_level: l, confidence_object: o1)
    q.without_confidence_level_id = l.id
    expect(q.all).to contain_exactly(o2)
  end

  specify '#with_confidence_level true' do
    c = FactoryBot.create(:valid_confidence, confidence_object: o1)
    q.confidences = true
    expect(q.all).to contain_exactly(o1)
  end

  specify '#with_confidence_level false' do
    c = FactoryBot.create(:valid_confidence, confidence_object: o1)
    q.confidences = false
    expect(q.all).to contain_exactly(o2)
  end

  specify '#exclude_confidences' do
    l = FactoryBot.create(:valid_confidence_level)
    c = FactoryBot.create(:valid_confidence, confidence_level: l, confidence_object: o1)
    q.confidence_level_id = l.id
    q.exclude_confidences = true
    expect(q.all).to contain_exactly(o2)
  end

  context '#exclude_confidences with both confidence_level_id and without_confidence_level_id set' do
    let!(:l1) { FactoryBot.create(:valid_confidence_level) }
    let!(:l2) { FactoryBot.create(:valid_confidence_level) }

    let!(:o3) { Otu.create!(name: 'Ghi 3') }
    let!(:o4) { Otu.create!(name: 'Jkl 4') }

    before do
      FactoryBot.create(:valid_confidence, confidence_level: l1, confidence_object: o1) # l1 only
      FactoryBot.create(:valid_confidence, confidence_level: l2, confidence_object: o2) # l2 only
      FactoryBot.create(:valid_confidence, confidence_level: l1, confidence_object: o3) # both
      FactoryBot.create(:valid_confidence, confidence_level: l2, confidence_object: o3) # both
      # o4 has neither

      q.confidence_level_id = l1.id
      q.without_confidence_level_id = l2.id
    end

    specify 'combined With/Without, not excluded' do
      # sanity check of the base (non-negated) combination: has l1 AND NOT l2
      expect(q.all).to contain_exactly(o1)
    end

    specify 'combined With/Without, excluded' do
      q.exclude_confidences = true
      # correct complement: NOT has_l1 OR has_l2 - includes o3 (has both) and
      # o4 (has neither), which a per-clause negation would wrongly drop/add
      expect(q.all).to contain_exactly(o2, o3, o4)
    end
  end

end
