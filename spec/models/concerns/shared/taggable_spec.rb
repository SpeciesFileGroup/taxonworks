require 'rails_helper'

describe 'Taggable', :type => :model do
  let(:class_with_tags) { TestTaggable.new } 

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
      before {
        @a = FactoryGirl.create(:valid_keyword)
        @b = Tag.create(tag_object: class_with_tags, keyword: @a)
      }

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
    specify 'has_tags? with no tags' do
      expect(class_with_tags.has_tags?).to eq(false)
    end

    specify 'has_tags? with a tag' do
      class_with_tags.tags << Tag.new(keyword: FactoryGirl.create(:valid_keyword))
      expect(class_with_tags.has_tags?).to eq(true)
    end
  end
end

class TestTaggable < ActiveRecord::Base
  include FakeTable
  include Shared::Taggable
end


