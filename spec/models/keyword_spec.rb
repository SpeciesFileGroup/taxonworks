require 'rails_helper'

describe Keyword, type: :model, group: :tags do
  let(:keyword) { FactoryGirl.build(:keyword) }

  context "validation" do
    before(:each) {  @k = FactoryGirl.create(:valid_keyword) }

    specify "can be used for tags" do
      t = Tag.new(keyword: @k, tag_object: FactoryGirl.build(:valid_otu))
      expect(t.save).to be_truthy
    end

    specify "can not be used for other things" do
      expect {c = CitationTopic.new(topic: @k)}.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end
  end

  context 'associations' do
    context 'has_many' do
      specify 'tags' do
        expect(keyword.tags << FactoryGirl.build(:valid_tag)).to be_truthy
      end
    end
  end

  specify 'tagged_objects' do
    expect(keyword).to respond_to(:tagged_objects)
    k = FactoryGirl.create(:valid_keyword)
    t1 = Tag.create(keyword: k, tag_object: FactoryGirl.create(:valid_otu))
    t2 = Tag.create(keyword: k, tag_object: FactoryGirl.create(:valid_specimen))
    expect(k.tagged_objects.count).to eq(2)
    expect(k.tags.count).to eq(2)
  end

  specify 'tagged_object_class_names' do
    expect(keyword).to respond_to(:tagged_object_class_names)
    k = FactoryGirl.create(:valid_keyword)
    t1 = Tag.create(keyword: k, tag_object: FactoryGirl.create(:valid_otu))
    expect(k.tagged_object_class_names).to eq(%w{Otu})

  end



end

