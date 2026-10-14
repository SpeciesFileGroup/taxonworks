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
end

