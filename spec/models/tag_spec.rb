require 'spec_helper'

describe Tag do

  let(:tag) {FactoryGirl.build(:tag)}

  context 'associations' do
    specify 'tag_object' do 
      expect(tag).to respond_to(:tag_object)
    end
  end

  context 'validation' do
    before(:each) do
      tag.valid?
    end

    specify 'a tag object is required' do 
      expect(tag.errors.include?(:tag_object)).to be_true
    end

    specify 'a keyword is required' do
      expect(tag.errors.include?(:keyword)).to be_true
    end

    specify 'a topic can not be used' do
      pending
    end

    specify 'a tagged object is only tagged once per keyword' do
      b = FactoryGirl.build(:valid_source_bibtex)
      k = FactoryGirl.build(:valid_keyword)
      tag.tag_object = b
      tag.keyword = k
      tag.valid?
      expect(tag.errors.include?(:keyword)).to be_false
      expect(tag.errors.include?(:tag_object)).to be_false
      tag.save!
      dupe_tag = FactoryGirl.build(:tag, keyword: k, tag_object: b) 
      dupe_tag.valid?
      expect(dupe_tag.errors.include?(:keyword_id)).to be_true
    end

    # TODO: Determine if we want to tag individual fields. 
    #  specify 'a attribute is actually a attribute of the tag object'
  end

end

