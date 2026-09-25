require 'rails_helper'

describe Queries::Gazetteer::Autocomplete, type: :model do
  let!(:g1) { FactoryBot.create(:valid_gazetteer, name: 'Uniquegaz North') }
  let!(:g2) { FactoryBot.create(:valid_gazetteer, name: 'Uniquegaz South') }

  specify 'matches by name' do
    q = described_class.new('Uniquegaz', project_id: g1.project_id)
    expect(q.autocomplete.map(&:id)).to contain_exactly(g1.id, g2.id)
  end

  context 'restrict_to' do
    specify 'restricts results to the given Gazetteers' do
      q = described_class.new('Uniquegaz', project_id: g1.project_id, restrict_to: Gazetteer.where(id: g2.id))
      expect(q.autocomplete.map(&:id)).to contain_exactly(g2.id)
    end
  end
end
