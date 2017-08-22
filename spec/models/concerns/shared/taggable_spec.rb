require 'rails_helper'

describe 'Taggable', type: :model, group: :tags do
  let(:class_with_tags) { TestTaggable.new } 
  let(:keyword) { FactoryGirl.create(:valid_keyword) }

  context 'associations' do
    specify 'has many tags' do
      expect(class_with_tags).to respond_to(:tags) 
      expect(class_with_tags.tags.to_a).to eq([]) # there are no tags yet.

      expect(class_with_tags.tags << FactoryGirl.build(:valid_tag)).to be_truthy
      expect(class_with_tags.tags.size).to eq(1)
      expect(class_with_tags.save).to be_truthy
      class_with_tags.reload

      expect(class_with_tags.tags.count).to eq(1)
    end
  end

  context 'scopes' do
    context '.with_tags' do
      let!(:b) { Tag.create(tag_object: class_with_tags, keyword: keyword)}

      specify 'without tags' do
        expect(class_with_tags.class.without_tags.count).to eq(0)
      end 

      specify 'with_tags' do
        expect(class_with_tags.class.with_tags.pluck(:id)).to eq( [ class_with_tags.id  ] )
      end
    end

    context '.without_tags' do
      specify 'without tags' do
        class_with_tags.save
        expect(TestTaggable.without_tags.pluck(:id)).to eq([class_with_tags.id])
      end 

      specify 'with_tags' do
        expect(class_with_tags.class.with_tags.to_a).to eq( [ ] )
      end
    end
  end

  context 'methods' do
    specify '#tagged? with no tags' do
      expect(class_with_tags.tagged?).to eq(false)
    end

    specify '#tagged? with a tag' do
      class_with_tags.tags << Tag.new(keyword: FactoryGirl.create(:valid_keyword))
      expect(class_with_tags.tagged?).to eq(true)
    end
    context 'object with notes on destroy' do
      specify 'attached notes are destroyed' do
        expect(Tag.count).to eq(0)
        class_with_tags.tags << Tag.new(keyword: FactoryGirl.create(:valid_keyword))
        class_with_tags.save
        expect(Tag.count).to eq(1)
        expect(class_with_tags.destroy).to be_truthy
        expect(Tag.count).to eq(0)
      end
    end
  end

  context 'use' do
    context 'when multiple nested tags are provided' do
      before{ 
        class_with_tags.tags_attributes = [
          {keyword_id: keyword.id },
          {keyword_id: nil}
        ]
      }

      context 'and one of them is invalid' do
        before { class_with_tags.save! }

        specify 'then the other is still created' do
          expect(class_with_tags.tags.first.keyword).to eq(keyword)
        end
      end
    end 
  end
end

class TestTaggable < ApplicationRecord
  include FakeTable
  include Shared::Taggable
end


