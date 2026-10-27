require 'rails_helper'
describe Topic, type: :model do
  let(:topic) { FactoryBot.build(:topic) }

  # validation is handlded in superclass or associated classes

  context 'associations' do
    context 'has many' do
      specify 'citation_topics' do
        expect(topic).to respond_to(:citation_topics)
      end

      specify 'contents' do
        expect(topic).to respond_to(:contents)
      end

      specify 'otus' do
        expect(topic).to respond_to(:otus)
      end

    end
  end

  context '.used_recently' do
    # select_optimized takes the first 10 (recent) and 5 (quick) of these.
    specify 'with no used_on, most recently updated first' do
      older = FactoryBot.create(:valid_topic)
      newer = FactoryBot.create(:valid_topic)
      middle = FactoryBot.create(:valid_topic)
      older.update_column(:updated_at, 3.days.ago)
      middle.update_column(:updated_at, 2.days.ago)
      newer.update_column(:updated_at, 1.day.ago)
      expect(Topic.used_recently(nil, older.project_id, nil, nil)).to eq([newer.id, middle.id, older.id])
    end
  end
end
